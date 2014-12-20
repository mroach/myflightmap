require 'geo'
require 'duration_estimator'

class Flight < ActiveRecord::Base
  extend FriendlyId
  include Formattable
  audited

  attr_accessor :is_duplicate

  belongs_to :depart_airport_info, :class_name => 'Airport', :foreign_key => 'depart_airport', :primary_key => 'iata_code'
  belongs_to :arrive_airport_info, :class_name => 'Airport', :foreign_key => 'arrive_airport', :primary_key => 'iata_code'
  belongs_to :trip, :class_name => 'Trip', :foreign_key => 'trip_id', :primary_key => 'id'
  belongs_to :airline
  belongs_to :user

  validates_presence_of :user_id, :depart_date, :depart_airport, :arrive_airport

  before_save :set_arrive_date!, :refresh_utc_times!, :update_duration!, :update_distance!
  after_save :update_related_trip!

  default_scope { order('depart_time_utc ASC') }

  friendly_id :description, use: [:slugged, :scoped], scope: :user

  formattable "%{flight_code} %{depart_airport}-%{arrive_airport} %{depart_date}"

  self.skip_time_zone_conversion_for_attributes = [:depart_time, :arrive_time]

  def self.seat_classes
    ["Economy", "Economy Plus", "Business", "First", "Suite"]
  end

  # TODO: Move to i18n file so these can be localised
  def self.seat_locations
    ["Window", "Middle", "Aisle", "Suite", "Other"]
  end

  def self.flight_roles
    ["Passenger", "Crew"]
  end

  def self.flight_purposes
    ["Pleasure", "Business", "Crew"]
  end

  def self.belonging_to(user_id)
    where("user_id = ?", user_id)
  end

  def self.recent
    reorder('depart_time_utc DESC')
  end

  def self.completed
    where("arrive_time_utc < ?", Time.now.utc)
  end

  def self.future
    where("depart_time_utc > ?", Time.now.utc)
  end

  def private?
    !self.is_public?
  end

  # Remove non word chars from the flight code when setting
  def flight_code=(value)
    value and write_attribute(:flight_code, value.sub(/\W/, '').upcase)
  end

  # Allow setting the airline ID by IATA code. e.g. airline_id = 'SQ'
  def airline_id=(value)
    logger.debug "airline_id to be set to #{value}"
    if value.is_a?(String) && value.match(Airline::IATA_CODE_REGEX)
      if airline = Airline.find_by_iata_code(value)
        write_attribute(:airline_id, airline.id)
        write_attribute(:airline_name, airline.name)
      end
    else
      write_attribute(:airline_id, value)
    end
  end

  # When setting the airline name, try to match the airline_id
  def airline_name=(value)
    if airline = Airline.find_by_name(value)
      write_attribute(:airline_id, airline.id)
    else
      logger.warn "Couldn't locate an airline called '#{value}'"
    end
    write_attribute(:airline_name, value)
  end

  # Just the airline code from the flight number
  # ex) in "NH263", "NH" is the airline code
  def airline_code
    return nil if flight_code.nil?
    return nil unless flight_code_has_airline_code?
    flight_code[0..1]
  end

  # From the flight code, only the flight number itself
  # ex) in "NH263", only "263"
  def flight_number
    return nil if flight_code.nil?
    return flight_code unless flight_code_has_airline_code?
    flight_code[2..flight_code.length - 1]
  end

  def depart_city
    depart_airport_info.city rescue nil
  end

  def arrive_city
    arrive_airport_info.city rescue nil
  end

  # Combine the depature date and time
  def depart_date_time
    return nil if depart_date.nil?
    h, m, s = depart_time.nil? ? [0, 0] : [depart_time.hour, depart_time.min]
    Time.new(depart_date.year, depart_date.month, depart_date.day, h, m)
  end

  # Combine the arrival date and time
  def arrive_date_time
    return nil if arrive_date.nil?
    h, m, s = arrive_time.nil? ? [0, 0] : [arrive_time.hour, arrive_time.min]
    Time.new(arrive_date.year, arrive_date.month, arrive_date.day, h, m)
  end

  # Return the time change in minutes between the origin and destination
  # Positive numbers going ahead, negative going back.
  # Depature and arrival datetime are used to determine which airport(s)
  # if any are in DST and account for that.
  # Eg) LHR-SIN: 420 (7 hours ahead)
  #     BKK-RGN: -30 (30 mintes behind)
  def time_change
    return 0 if [depart_date_time, arrive_date_time, depart_airport_info, arrive_airport_info].any? { |e| e.nil? }
    depart_zone = TZInfo::Timezone.get(depart_airport_info.timezone).period_for_local(depart_date_time)
    arrive_zone = TZInfo::Timezone.get(arrive_airport_info.timezone).period_for_local(arrive_date_time)
    (arrive_zone.offset.utc_total_offset - depart_zone.offset.utc_total_offset)
  end

  def in_the_air?(refdate = nil)
    # Require all the depart date/time fields and airports
    return false if depart_time_utc.empty? || arrive_time_utc.empty?
    # Use UTC now as a ref if one wasn't specified
    refdate = Time.now.utc if refdate.nil?
    refdate >= depart_time_utc && refdate < arrive_time_utc
  end

  # Determine if the flight code contains the airline code
  # Some users may have only entered the flight number
  # Airline codes MUST contain a letter, so if the first two
  # chars don't contain a letter, it's only the flight number
  def flight_code_has_airline_code?
    !flight_code.blank? && flight_code.match(/^(?: [A-Z]{2} | [A-Z]\d | \d[A-Z] )/xi)
  end

  def arrive_time_offset
    offset = (arrive_date - depart_date).to_i
    case
      when offset < 0 then "-#{offset}"
      when offset > 0 then "+#{offset}"
      else ""
    end
  end

  # Aircraft model plus the registration and aircraft name if available
  def aircraft_description
    s = aircraft_type

    extra = []
    extra.push aircraft_registration unless aircraft_registration.nil?
    extra.push "\"#{aircraft_name}\"" unless aircraft_name.nil?

    if !extra.empty?
      s = "#{s} (#{extra.join(' ')})"
    end
    s
  end

  def description
    "#{flight_code} #{depart_airport}-#{arrive_airport} #{depart_date.strftime('%Y-%m-%d')}"
  end

  def find_duplicate
    Flight.find_by(
      user_id: user_id,
      depart_date: depart_date,
      depart_airport: depart_airport,
      flight_code: flight_code
    )
  end

  def has_duplicate?
    !find_duplicate.nil?
  end

  def is_duplicate?
    @is_duplicate
  end

  def self.detect_duplicates(flights)
    flights.each { |f| f.is_duplicate = f.has_duplicate? }
  end

  def should_generate_new_friendly_id?
    flight_code_changed? ||
      depart_airport_changed? ||
      arrive_airport_changed? ||
      depart_date_changed? ||
      super
  end

  def normalize_friendly_id(string)
    super.upcase
  end

  private

  # If no arrival date was set, copy it from the departure date
  def set_arrive_date!
    return unless arrive_date.nil?
    self.arrive_date = self.depart_date
  end

  def update_related_trip!
    if !trip.nil? && (trip_id_changed? || depart_date_changed? || arrive_date_changed?)
      trip.refresh_dates!
    end
  end

  def refresh_utc_times!
    return if depart_time_utc_changed? || arrive_time_utc_changed?

    if depart_airport_info.present?
      self.depart_time_utc = time_to_utc(depart_airport_info.timezone, depart_date_time)
    end

    if arrive_airport_info.present?
      self.arrive_time_utc = time_to_utc(arrive_airport_info.timezone, arrive_date_time)
    end
  end

  def update_duration!
    return if duration_changed?

    blank_time = Time.utc(2000, 1, 1, 0, 0, 0)

    should_estimate_duration = depart_time.blank? ||
      arrive_time.blank? ||
      depart_time == blank_time ||
      arrive_time == blank_time

    if should_estimate_duration
      can_estimate_duration = depart_airport_info.present? && arrive_airport_info.present?

      if can_estimate_duration
        self.duration = DurationEstimator.new.estimate(
          depart_airport_info.coordinates, arrive_airport_info.coordinates)
      else
        logger.info "Can't estimate duration. Airport data is missing."
      end
    else
      if depart_time_utc.present? && arrive_time_utc.present?
        self.duration = (arrive_time_utc - depart_time_utc)
      end
    end
  end

  def update_distance!
    return if distance_changed?
    if depart_airport_info.present? && arrive_airport_info.present?
      self.distance = Geo.distance_between(
        depart_airport_info.coordinates,
        arrive_airport_info.coordinates
      ).to_i
    end
  end

  def time_to_utc(timezone, time)
    begin
      TZInfo::Timezone.get(timezone).local_to_utc(time)
    rescue TZInfo::PeriodNotFound
      logger.error "Unable to convert '#{time}' in zone '#{timezone}'"
    end
  end

end
