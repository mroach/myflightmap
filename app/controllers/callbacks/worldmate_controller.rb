require 'worldmate'

class Callbacks::WorldmateController < ActionController::Base
  def receive
    xml_string = request.body.read
    parser = Worldmate::Parser.new(xml_string)

    parser.trip.save! unless parser.trip.flights.none?

    render text: 'OK'
  end
end
