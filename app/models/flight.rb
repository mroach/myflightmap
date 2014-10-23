class Flight < ActiveRecord::Base

  attr_accessor :is_duplicate

  belongs_to :depart_airport_info, :class_name => 'Airport', :foreign_key => 'depart_airport', :primary_key => 'iata_code'
  belongs_to :arrive_airport_info, :class_name => 'Airport', :foreign_key => 'arrive_airport', :primary_key => 'iata_code'
  belongs_to :trip
  belongs_to :airline

  self.skip_time_zone_conversion_for_attributes = [:depart_time, :arrive_time]

  # conform to bool convention
  def is_duplicate?
    @is_duplicate
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
    return nil if [depart_date, depart_time].any? { |e| e.nil? }
    Time.new(depart_date.year, depart_date.month, depart_date.day, depart_time.hour, depart_time.min)
  end

  # Combine the arrival date and time
  def arrive_date_time
    return nil if [arrive_date, arrive_time].any? { |e| e.nil? }
    Time.new(arrive_date.year, arrive_date.month, arrive_date.day, arrive_time.hour, arrive_time.min)
  end

  # Return the time change in minutes between the origin and destination
  # Positive numbers going ahead, negative going back.
  # Depature and arrival datetime are used to determine which airport(s)
  # if any are in DST and account for that.
  # Eg) LHR-SIN: 420 (7 hours ahead)
  #     BKK-RGN: -30 (30 mintes behind)
  def time_change
    return 0 if [depart_date_time, arrive_date_time].any? { |e| e.nil? }
    depart_zone = TZInfo::Timezone.get(depart_airport_info.timezone).period_for_local(depart_date_time)
    arrive_zone = TZInfo::Timezone.get(arrive_airport_info.timezone).period_for_local(arrive_date_time)
    (arrive_zone.offset.utc_total_offset - depart_zone.offset.utc_total_offset) / 60
  end

  def in_the_air?(refdate = nil)
    # Require all the depart date/time fields and airports
    return false if [depart_date, depart_time, arrive_date, arrive_time, depart_airport, arrive_airport].any? { |e| e.nil? }
    # Use UTC now as a ref if one wasn't specified
    refdate = Time.now.utc if refdate.nil?
    # return false immediately if the departure datetime is over 48 hours away
    # to make this method perform well over large data sets
    return false if (refdate - depart_date_time).abs > (48 * 60 * 60)
    # Convert local depart/arrive times to UTC
    depart_time_utc = TZInfo::Timezone.get(depart_airport_info.timezone).local_to_utc(depart_date_time)
    arrive_time_utc = TZInfo::Timezone.get(arrive_airport_info.timezone).local_to_utc(arrive_date_time)
    # And see if the flight is in the air
    refdate > depart_date_time && refdate < arrive_date_time
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

  def duration_formatted
    hours = duration / 60
    minutes = duration - (hours * 60)
    "%01d:%02d" % [hours, minutes]
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

  def self.detect_duplicates(flights)
    flights.each { |f| f.is_duplicate = f.has_duplicate? }
  end

end
