class StatsController < ApplicationController

  before_action :set_user
  skip_before_filter :authenticate_user!

  def airlines
    flights = Flight.belonging_to(@user.id).visible
    @airline_stats = FlightsHelper.airline_stats(flights)
  end

  private

  def set_user
    @user = User.find_by_username(params[:username])
  end
end
