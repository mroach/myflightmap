class TripsController < ApplicationController
  before_action :set_user
  before_action :set_trip, only: [:show, :edit, :update, :destroy]
  before_action :authenticate!, except: [:index, :show]
  skip_before_filter :authenticate_user!, only: [:index, :show]

  # GET /trips
  # GET /trips.json
  def index
    if current_user.present?
      @trips = Trip.belonging_to(@user.id).visible_to(current_user.id).reverse
      @show_controls = @user.id == current_user.id
    else
      @trips = Trip.belonging_to(@user.id).visible.reverse
      @show_controls = false
    end
  end

  # GET /trips/1
  # GET /trips/1.json
  def show
    if !@trip.is_visible_to?((current_user.id rescue -1))
      not_found
    end

    if current_user.present?
      flights = @trip.flights.visible_to(current_user)
    else
      flights = @trip.flights.visible
    end

    @stats = FlightsHelper.generate_statistics(flights)
  end

  # GET /trips/new
  def new
    @trip = Trip.new
  end

  # GET /trips/1/edit
  def edit
  end

  # POST /trips
  # POST /trips.json
  def create
    @trip = Trip.new(trip_params)
    @trip.user_id = current_user.id

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
    @trip.destroy
    respond_to do |format|
      format.html { redirect_to trips_url }
      format.json { head :no_content }
    end
  end

  private
    def authenticate!
      not_found unless user_signed_in? && (
          @trip.nil? ||
          (current_user.admin? || current_user == @trip.user)
        )
    end

    def set_user
      @user = User.find_by_username!(params[:username])
    end

    def set_trip
      @trip = @user.trips.friendly.find(params[:id])
      @show_controls = current_user.present? && @trip.user_id == current_user.id
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def trip_params
      params.require(:trip).permit(:user_id, :name, :purpose, :is_public)
    end
end
