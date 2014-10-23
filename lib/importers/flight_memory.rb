require 'nokogiri'
require 'date'
require 'json'
require 'logging'

module Importers
  class FlightMemory
    include Logging

    def scrape_html(str)
      # convert non-breaking spaces to normal spaces
      str.gsub!(/\u00A0/, ' ')
      str.gsub!(/&nbsp;?/, ' ')

      # parse the string as an HTML document
      page = Nokogiri::HTML(str)

      # data lives in the second table under the .container div
      # the valign="top" happens to return only data rows. no ads or header
      rows = page.css('.container > table > tr[valign="top"]')

      flights = rows.map { |r| parse_row(r) }

      flights
    end

    protected

    def parse_row(row)
      cells = row.css('>td')

      times = cells[1].children.map { |c| c.text.strip }.reject(&:empty?)

      # the flight length and duration cell is a th, not td. weird.
      lengths = row.css('>th')[0].css('tr').map(&:text)

      route = cells[6].children.map(&:text).reject(&:empty?)

      seat_info = cells[8]

      seat = seat_info.children[0].text.split('/')

      misc = seat_info.css('small').children.to_s.split('<br>')
      aircraft_misc = cells[7].children.to_s.split('<br>')

      depart_date = parse_date(times[0])
      arrive_date = depart_date
      arrive_time = times[2]

      if !arrive_time.blank?
        # see if the arrival time has a day offset
        # if so, adjust the arrival date accordingly
        arrive_offset = arrive_time.match(/[+-]\d$/)

        if arrive_offset
          # the format is "+1" or "-1" so it parses cleanly as an integer
          arrive_date += arrive_offset.to_s.to_i
          # update the arrive_time to be just the time without the offset
          arrive_time = arrive_offset.pre_match
        end
      end

      data = {
        depart_date: depart_date,
        depart_time: parse_time(times[1]),

        # TODO: Parse arrive time for +1, +2, etc
        #       and update arrive_date accordingly
        arrive_date: arrive_date,
        arrive_time: parse_time(arrive_time),

        depart_airport: cells[2].text,
        arrive_airport: cells[4].text,

        distance: parse_distance(lengths[0]).to_s,
        duration: parse_duration(lengths[1]).to_s,

        airline_name: route[0],
        flight_code: route[1],

        aircraft_type: aircraft_misc[0],
        aircraft_registration: aircraft_misc[1],
        aircraft_name: aircraft_misc[2],

        seat: seat[0],
        seat_class: misc[0],
        seat_location: seat[1],

        flight_role: misc[1],
        purpose: misc[2]
      }

      data.each { |k,v| data[k] = scrub_value(v) }

      logger.debug "Parsed flight: #{data}"

      Flight.new(data)
    end

    def scrub_value(str)
      return nil if str.nil?

      if str.class == Date
        return str.strftime('%Y-%m-%d')
      end

      if str.class == Time
        return str.strftime('%H:%M')
      end

      #str.gsub!(/\u00A0/, ' ')
      str.strip!
      str.empty? ? nil : str
    end

    # Convert the MM-DD-YYYY or DD.MM.YYYY date to a Date object
    def parse_date(str)
      return nil if str.nil? || str.empty?
      return "#{str}-01-01" if str.match(/^\d{4}/)
      format = str.match(/^\d{2}\./) ? '%d.%m.%Y' : '%m-%d-%Y'
      begin
        return Date.strptime(str, format).to_date
      rescue
        logger.warn "Failed to parse date [#{str}] with [#{format}] format"
        return nil
      end
    end

    # Convert the 12 or 24 hour time into a Time object
    # 12-hr: 02:30 pm
    # 24-hr: 14:30
    def parse_time(str)
      return nil if str.nil? || str.empty?

      # make sure it looks like a time
      # i've seen arrive time cells just be "+1" and nothing else
      return nil unless str.match(/^\d+:\d+/)

      format = str.match(/[ap]m$/) ? '%I:%M %P' : '%H:%M'
      Time.strptime(str, format).to_time
    end

    # Convert the "HH:MM h" duration into an integer of minutes
    def parse_duration(str)
      return nil if str.nil? || str.empty?
      parts = str.match(/^(?<h>\d+):(?<m>\d+) h$/)
      hours = parts[:h].to_i
      minutes = parts[:m].to_i
      hours * 60 + minutes
    end

    # Convert the distance like "1,563 km" to an integer
    # Units in miles (e.g. "1,344 mi") are converted to km
    def parse_distance(str)
      return nil if str.nil? || str.empty?
      parts = str.match(/^(?<num>[\d,]+) (?<unit>mi|km)$/)
      num = parts[:num].sub(/,/,'').to_i
      if parts[:unit] == 'mi'
        num *= 1.60934
      end
      num
    end
  end
end
