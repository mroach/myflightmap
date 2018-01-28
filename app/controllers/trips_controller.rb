class TripsController < ApplicationController
  before_action :set_user
  before_action :set_trip, only: %i(show edit update destroy)
  skip_before_action :authenticate_user!, only: %i(index show)

  # GET /trips
  # GET /trips.json
  def index
    @trips = policy_scope(Trip).belonging_to(@user.id).includes(flights: [:airline, :depart_airport_info, :arrive_airport_info]).decorate.reverse
    @show_controls = current_user.present? && @user.id == current_user.id
  end

  # GET /trips/1
  # GET /trips/1.json
  def show
    authorize @trip
    @flights = policy_scope(@trip.flights).decorate
    @stats = Stats.from_flights(@trip.flights)
  end

  # GET /trips/new
  def new
    @trip = Trip.new
    authorize @trip, :new?
  end

  # GET /trips/1/edit
  def edit
    authorize @trip, :edit?
  end

  # POST /trips
  # POST /trips.json
  def create
    @trip = Trip.new(trip_params)
    @trip.user_id = current_user.id

    authorize @trip, :create?

    respond_to do |format|
      if @trip.save
        format.html { redirect_to @trip, notice: 'Trip was successfully created.' }
        format.json { render action: 'show', status: :created, location: @trip }
      else
        format.html { render action: 'new' }
        format.json { render json: @trip.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /trips/1
  # PATCH/PUT /trips/1.json
  def update
    authorize @trip, :update?
    respond_to do |format|
      if @trip.update(trip_params)
        format.html { redirect_to @trip, notice: 'Trip was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @trip.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /trips/1
  # DELETE /trips/1.json
  def destroy
    authorize @trip, :destroy?
    @trip.destroy
    respond_to do |format|
      format.html { redirect_to trips_url }
      format.json { head :no_content }
    end
  end

  private

  def set_user
    @user = User.find_by_username!(params[:username])
  end

  def set_trip
    @trip = @user.trips.friendly.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def trip_params
    params.require(:trip).permit(:user_id, :name, :purpose, :is_public)
  end
end
