require 'worldmate'

class Callbacks::WorldmateController < ActionController::Base
  def receive
    xml_string = request.body.read

    logger.debug "Received Worldmate callback:\n#{xml_string}"

    log_entry = CallbackLog.create(
      provider: :worldmate,
      target_type: 'User',
      status: :received,
      url: request.original_url,
      data: xml_string
    )

    parser = Worldmate::Parser.new(xml_string)

    log_entry.update_attributes({ target_id: parser.user.id, status: :parsed})

    if parser.trip.flights.none?
      log_entry.update_attribute(:status, :ignored)
    else
      if parser.trip.save
        log_entry.update_attribute(:status, :success)
      else
        log_entry.update_attribute(:status, :error)
        logger.warn "Failed to save Worldmate import. See callback log ##{log_entry.id}"
      end
    end

    render text: log_entry.status.to_s.upcase
  end
end
