require 'importers/flight_memory'

module Import
  class FlightMemoryController < ApplicationController

    before_filter :authenticate_user!

    def index
    end

    def upload
      #@result = params[:import].inspect
      file = params[:import]["html"]
      #html = file.read.encode('utf-8')
      html = File.open(file.tempfile, 'r:ISO-8859-1') { |f| f.read }.encode('utf-8')

      parser = Importers::FlightMemory.new
      @flights = parser.scrape_html(html)

      if @flights.nil? || @flights.empty?
        flash[:error] = "Failed to import"
        redirect_to action: :index
      end

      @flights.each { |f| f.user_id = current_user.id }

      # See if the import contains flights that already exist in the database for this user
      # Searching on: depart date, depart airport, flight code
      Flight.detect_duplicates(@flights)
      @flights.select { |f| !f.is_duplicate? }.each { |f| f.save }

      @flights_created = @flights.select { |f| !f.new_record? }.length
      @duplicates_skipped = @flights.select { |f| f.is_duplicate? }.length
    end
  end
end
