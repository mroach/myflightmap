require "time"

class FlightsController < ApplicationController
  before_action :set_user
  before_action :set_flight, only: [:show, :edit, :update, :destroy]
  before_action :load_helper_data, only: [:new, :edit]
  skip_before_filter :authenticate_user!, only: [:index, :show]

  # GET /flights
  # GET /flights.json
  def index
    @flights = policy_scope(Flight).belonging_to(@user.id).decorate.reverse
    @show_controls = current_user.present? && @user.id == current_user.id

    @list_style = params[:style] || "large"
    @batch_editing = !params[:batch_editing].nil?

    if @batch_editing
      load_helper_data
    end
  end

  # GET /flights/1
  # GET /flights/1.json
  def show
    authorize @flight
  end

  # GET /flights/new
  def new
    @flight = Flight.new(flight_params)
    authorize @flight, :new?
  end

  # GET /flights/1/edit
  def edit
    authorize @flight, :edit?
  end

  # POST /flights
  # POST /flights.json
  def create
    # if necessary create a new trip
    @flight = Flight.new(flight_params)
    @flight.user_id = current_user.id
    authorize @flight, :create?

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
    authorize @flight, :update?
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
    authorize @flight, :update?

    # Get the name of the field to update and the list of records to update
    field_to_update = params[:field_to_update].to_sym
    records_to_update = params[:records_to_update].split(/,/)

    # Restrict the updatable flights list to those owned by the current user
    # AND those selected by the checkboxes on the batch update form
    flights = Flight.where("user_id = ? AND id IN (?)", current_user.id, records_to_update)

    # Use the flight_params strong parameters to allow any field
    # to be batch updated
    value = flight_params[field_to_update]
    flights.each { |e| e.send("#{field_to_update}=", value); e.save! }

    redirect_to flights_path,
      notice: "Updated %s %s" % [records_to_update.length, "flights".pluralize(records_to_update.length)]
  end

  # DELETE /flights/1
  # DELETE /flights/1.json
  def destroy
    authorize @flight, :destroy?

    @flight.destroy
    respond_to do |format|
      format.html { redirect_to flights_url }
      format.json { head :no_content }
    end
  end

  private
    def set_user
      @user = User.find_by_username!(params[:username])
    end

    def set_flight
      @flight = @user.flights.friendly.find(params[:id]).decorate
    end

    def load_helper_data
      @trips = Trip.where(user_id: current_user.id).select("id, name")
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def flight_params
      return {} if !params || !params[:flight]
      if params[:flight][:trip_id] and params[:flight][:trip_id][0..2] == "-1:"
        logger.debug "Creating a new trip from #{params[:flight][:trip_id]}"
        trip_name = params[:flight][:trip_id][3..-1]
        trip = Trip.find_or_create_by(user_id: current_user.id, name: trip_name)
        params[:flight][:trip_id] = trip.id
        logger.debug "Found or created trip #{trip.id}"
      end
      params.require(:flight).permit(:trip_id, :flight_code, :depart_airport, :depart_date, :depart_time, :arrive_airport, :arrive_date, :arrive_time, :distance, :duration, :airline_id, :airline_name, :aircraft_name, :aircraft_type, :aircraft_registration, :flight_role, :purpose, :seat, :seat_class, :seat_location, :is_public)
    end
end
