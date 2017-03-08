require 'nokogiri'

module Worldmate
  class Parser
    include Logging

    attr_reader :user, :trip, :flights, :status

    def success?
      [:success, :partial_success].include?(@status)
    end

    def initialize(xml_string)
      xml_doc = Nokogiri::XML(xml_string)
      xml_doc.remove_namespaces!

      @status = xml_doc.css('status').text.downcase.to_sym
      recipient = xml_doc.css('end-user-emails user').attribute('email').text
      user_id_hash = recipient.scan(/\A[^@]+/).first.to_s.upcase
      @user = User.find_by_id_hash(user_id_hash)

      unless success?
        logger.info "Worldmate failed to parse the itinerary"
        return
      end

      subject = xml_doc.css('header[name="Subject"]').attribute('value').text
      recipient = xml_doc.css('end-user-emails user').attribute('email').text

      if @user.nil?
        logger.warn "No user found with ID hash #{user_id_hash}"
        return
      end

      @trip = Trip.find_or_initialize_by(user_id: user.id, name: subject) do |t|
        t.audit_comment = "Created by Worldmate"
      end

      @trip.flights << xml_doc.css('items flight').map do |f|
        airline_code  = f.css("details").attribute('airline-code').text
        airline_name  = f.css("provider-details name").text
        flight_number = f.css("details").attribute('number').text

        depart      = f.css("departure airport-code").text
        depart_date = DateTime.iso8601(f.css('departure local-date-time').text)
        arrive      = f.css("arrival airport-code").text
        arrive_date = DateTime.iso8601(f.css('arrival local-date-time').text)
        airline     = Airline.find_by_iata_code(airline_code)

        Flight.find_or_initialize_by(
          user:           @user,
          trip:           @trip,
          flight_code:    "#{airline_code}#{flight_number}",
          airline:        airline,
          airline_name:   airline.present? ? airline.name : airline_name,
          depart_airport: depart,
          arrive_airport: arrive,
          depart_date:    depart_date,
          depart_time:    depart_date,
          arrive_date:    arrive_date,
          arrive_time:    arrive_date
        ) { |f| f.audit_comment = "Created by Worldmate" }
      end
    end
  end
end
