require 'worldmate'

class Callbacks::WorldmateController < ActionController::Base
  def receive
    xml_string = request.body.read
    parser = Worldmate::Parser.new(xml_string)

    parser.trip.save!

    render text: 'OK'
  end
end
