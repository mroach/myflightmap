 require 'gcmap'
 require 'geo'

 class AirportsController < ApplicationController
  before_action :set_airport, only: [:show, :edit, :update, :destroy]
  before_action :reject_non_admin!, except: [:show, :search]

  # GET /airports
  # GET /airports.json
  def index
    @airports = Airport.all
  end

  # GET /airports/1
  # GET /airports/1.json
  def show
  end

  # GET /airports/new
  def new
    @airport = Airport.new
  end

  # GET /airports/1/edit
  def edit
    @timezones = TZInfo::Timezone.all_identifiers
  end

  # POST /airports
  # POST /airports.json
  def create
    @airport = Airport.new(airport_params)

    respond_to do |format|
      if @airport.save
        format.html { redirect_to @airport, notice: 'Airport was successfully created.' }
        format.json { render action: 'show', status: :created, location: @airport }
      else
        format.html { render action: 'new' }
        format.json { render json: @airport.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /airports/1
  # PATCH/PUT /airports/1.json
  def update
    respond_to do |format|
      if @airport.update(airport_params)
        format.html { redirect_to @airport, notice: 'Airport was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @airport.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /airports/1
  # DELETE /airports/1.json
  def destroy
    @airport.destroy
    respond_to do |format|
      format.html { redirect_to airports_url }
      format.json { head :no_content }
    end
  end

  # GET /airports/search?q=SEARCHTERM
  def search
    results = []
    results += Airport.where("iata_code LIKE ?", params[:q].upcase)
    results += Airport.where("LOWER(description) LIKE ?", "%#{params[:q].downcase}%")
    render json: results
  end

  # Update an airport's basic info from GCMap
  # Refresh name, city, country, description, timezone
  def update_from_external
    render status: 404 unless current_user.admin?

    iata_code = params[:id].to_s.upcase

    # Load new data and existing airport
    @new_data = Gcmap.new.get_airport(iata_code)
    @airport = Airport.find_by(iata_code: iata_code)
    fields_to_update = %w(name city country description timezone)

    # Only permit updating certain fields and fields that changed value
    attributes = @new_data.attributes.select do |attr, value|
      fields_to_update.include?(attr.to_s) && @airport[attr] != value
    end
    logger.info "Updating airport #{@airport} with: #{attributes.inspect}"

    # Set audit comment so we know from whence the changes hath come
    attributes[:audit_comment] = 'Updated from GCMap'

    # And save the changes
    if @airport.update_attributes(attributes)
      redirect_to @airport, notice: 'Updated successfully'
    else
      redirect_to @airport, alert: 'Update failed'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_airport
      iata_code = params[:id].to_s.upcase
      @airport = Airport.find_by(iata_code: iata_code)
      if @airport.nil?
        @airport = Gcmap.new.get_airport(iata_code)
        if @airport
          @airport.audit_comment = "Created by GCMap"
          @airport.save
        end
      end
      raise ActiveRecord::RecordNotFound if @airport.nil?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def airport_params
      params.require(:airport).permit(:iata_code, :icao_code, :name, :city, :country, :latitude, :longitude, :timezone, :description)
    end
end
