require 'countries'

class MapController < ApplicationController

  before_action :set_user
  skip_before_filter :authenticate_user!, only: [:index]

  def show
    flights = Flight.belonging_to(@user.id).visible
    @stats = FlightsHelper.generate_statistics(flights)
  end

  private

  def set_user
    @user = User.find_by_username(params[:username])
  end
end
