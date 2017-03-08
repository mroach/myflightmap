require 'importers/flight_memory'

module Import
  class FlightMemoryController < ApplicationController
    before_filter :authenticate_user!
    skip_after_filter :verify_authorized
    skip_after_filter :verify_policy_scoped

    def index
    end

    def upload
      file = params[:import]['html']
      html = File.open(file.tempfile, 'r:ISO-8859-1', &:read).encode('utf-8')

      parser = Importers::FlightMemory.new
      @flights = parser.scrape_html(html)

      if @flights.nil? || @flights.empty?
        flash[:error] = 'Failed to import'
        redirect_to action: :index
      end

      @flights.each { |f| f.user_id = current_user.id }

      # See if the import contains flights that already exist in the database for this user
      # Searching on: depart date, depart airport, flight code
      Flight.detect_duplicates(@flights)
      @flights.select { |f| !f.is_duplicate? }.each(&:save)

      @flights_created = @flights.select { |f| !f.new_record? }.length
      @duplicates_skipped = @flights.select(&:is_duplicate?).length
    end
  end
end
