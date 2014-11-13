require "time"

class FlightsController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:index]
  before_action :set_flight, only: [:show, :edit, :update, :destroy]
  before_action :load_helper_data, only: [:new, :edit]

  # GET /flights
  # GET /flights.json
  def index
    user = User.find_by_username(params[:username])

    if current_user.nil?
      @flights = Flight.belonging_to(user.id).visible.reverse
      @show_controls = false
    else
      @flights = Flight.belonging_to(user.id).visible_to(current_user.id).reverse
      @show_controls = user.id == current_user.id
    end

    @list_style = params[:style] || "large"
    @batch_editing = !params[:batch_editing].nil?

    if @batch_editing
      load_helper_data
    end
  end

  # GET /flights/1
  # GET /flights/1.json
  def show
  end

  # GET /flights/new
  def new
    @flight = Flight.new(flight_params)
  end

  # GET /flights/1/edit
  def edit
  end

  # POST /flights
  # POST /flights.json
  def create
    # if necessary create a new trip
    @flight = Flight.new(flight_params)
    @flight.user_id = current_user.id

    respond_to do |format|
      if @flight.save
        format.html { redirect_to @flight, notice: 'Flight was successfully created.' }
        format.json { render action: 'show', status: :created, location: flights_url }
      else
        format.html { render action: 'new' }
        format.json { render json: @flight.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /flights/1
  # PATCH/PUT /flights/1.json
  def update
    respond_to do |format|
      if @flight.update(flight_params)
        format.html { redirect_to @flight, notice: 'Flight was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @flight.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH /flights/batch_update
  def batch_update
    # Get the name of the field to update and the list of records to update
    field_to_update = params[:field_to_update].to_sym
    records_to_update = params[:records_to_update].split(/,/)

    # Restrict the updatable flights list to those owned by the current user
    # AND those selected by the checkboxes on the batch update form
    flights = Flight.where("user_id = ? AND id IN (?)", current_user.id, records_to_update)

    # Use the flight_params strong parameters to allow any field
    # to be batch updated
    value = flight_params[field_to_update]
    flights.each { |e| e[field_to_update] = value; e.save! }

    redirect_to user_flights_path,
      notice: "Updated %s %s" % [records_to_update.length, "flights".pluralize(records_to_update.length)]
  end

  # DELETE /flights/1
  # DELETE /flights/1.json
  def destroy
    @flight.destroy
    respond_to do |format|
      format.html { redirect_to flights_url }
      format.json { head :no_content }
    end
  end

  # GET /flights/duration?from=SIN&departs=2014-01-01T14:45&to=CPH&arrives=2014-01-01T07:30
  def duration
    from_airport = Airport.find_by iata_code: params[:from]
    to_airport = Airport.find_by iata_code: params[:to]
    depart_time = parse_time_with_zone(params[:departs], from_airport.timezone)
    arrive_time = parse_time_with_zone(params[:arrives], to_airport.timezone)
    render json: {
      departs_utc: depart_time,
      arrives_utc: arrive_time,
      duration: (arrive_time - depart_time) / 60
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_flight
      @flight = User.find_by_username(params[:username]).flights.friendly.find(params[:id])
    end

    def load_helper_data
      @trips = Trip.where(user_id: current_user.id).select("id, name")
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def flight_params
      return {} if !params || !params[:flight]
      if params[:flight][:trip_id][0..2] == "-1:"
        logger.debug "Creating a new trip from #{params[:flight][:trip_id]}"
        trip_name = params[:flight][:trip_id][3..-1]
        trip = Trip.find_or_create_by(user_id: current_user.id, name: trip_name)
        params[:flight][:trip_id] = trip.id
        logger.debug "Found or created trip #{trip.id}"
      end
      params.require(:flight).permit(:trip_id, :flight_code, :depart_airport, :depart_date, :depart_time, :arrive_airport, :arrive_date, :arrive_time, :distance, :duration, :airline_id, :airline_name, :aircraft_name, :aircraft_type, :aircraft_registration, :flight_role, :purpose, :seat, :seat_class, :seat_location, :is_public)
    end

    def parse_time_with_zone(str, zone_id)
      tz = TZInfo::Timezone.get(zone_id)
      t = Time.parse(str)
      tz.local_to_utc(t)
    end
end
