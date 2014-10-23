class AirlinesController < ApplicationController
  before_action :set_airline, only: [:show, :edit, :update, :destroy]

  # GET /airlines
  # GET /airlines.json
  def index
    @airlines = Airline.all.sort_by { |a| a.name }
  end

  # GET /airlines/1
  # GET /airlines/1.json
  def show
  end

  # GET /airlines/new
  def new
    @airline = Airline.new
  end

  # GET /airlines/1/edit
  def edit
  end

  # POST /airlines
  # POST /airlines.json
  def create
    @airline = Airline.new(airline_params)

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
    @airline.destroy
    respond_to do |format|
      format.html { redirect_to airlines_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_airline
      @airline = Airline.find_by iata_code: params[:id]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def airline_params
      params.require(:airline).permit(:iata_code, :icao_code, :name, :country, :logo, :alliance)
    end
end
