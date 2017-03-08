class AirlinesController < ApplicationController
  before_action :set_airline, only: %i(show edit update destroy)

  # GET /airlines
  # GET /airlines.json
  def index
    @airlines = policy_scope(Airline).order(:name)
  end

  # GET /airlines/1
  # GET /airlines/1.json
  def show
    authorize @airline
  end

  # GET /airlines/new
  def new
    @airline = Airline.new
    authorize @airline, :new?
  end

  # GET /airlines/1/edit
  def edit
    authorize @airline, :edit?
  end

  # POST /airlines
  # POST /airlines.json
  def create
    @airline = Airline.new(airline_params)
    authorize @airline, :create?

    respond_to do |format|
      if @airline.save
        format.html { redirect_to @airline, notice: 'Airline was successfully created.' }
        format.json { render action: 'show', status: :created, location: @airline }
      else
        format.html { render action: 'new' }
        format.json { render json: @airline.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /airlines/1
  # PATCH/PUT /airlines/1.json
  def update
    authorize @airline, :update?
    respond_to do |format|
      if @airline.update(airline_params)
        format.html { redirect_to @airline, notice: 'Airline was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @airline.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /airlines/1
  # DELETE /airlines/1.json
  def destroy
    authorize @airline, :destroy?
    @airline.destroy
    respond_to do |format|
      format.html { redirect_to airlines_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_airline
    @airline = Airline.find_by_iata_code!(params[:id].to_s.upcase)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def airline_params
    params.require(:airline).permit(:iata_code, :icao_code, :name, :country, :logo, :alliance)
  end
end
