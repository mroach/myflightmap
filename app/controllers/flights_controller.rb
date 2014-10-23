require "time"

class FlightsController < ApplicationController
  before_action :set_flight, only: [:show, :edit, :update, :destroy]

  # GET /flights
  # GET /flights.json
  def index
    @flights = Flight.all.order("depart_date DESC, depart_time DESC").all
  end

  # GET /flights/1
  # GET /flights/1.json
  def show
  end

  # GET /flights/new
  def new
    @flight = Flight.new
  end

  # GET /flights/1/edit
  def edit
  end

  # POST /flights
  # POST /flights.json
  def create
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
      @flight = Flight.find_by(id: params[:id], user_id: current_user.id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def flight_params
      params.require(:flight).permit(:trip_id, :flight_code, :depart_airport, :depart_date, :depart_time, :arrive_airport, :arrive_date, :arrive_time, :distance, :duration, :airline_id, :airline_name, :aircraft_name, :aircraft_type, :aircraft_registration, :flight_role, :purpose, :seat, :seat_class, :seat_location)
    end

    def parse_time_with_zone(str, zone_id)
      tz = TZInfo::Timezone.get(zone_id)
      t = Time.parse(str)
      tz.local_to_utc(t)
    end
end
