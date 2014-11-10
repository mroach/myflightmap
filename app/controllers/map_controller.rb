class MapController < ApplicationController

  before_action :set_user
  skip_before_filter :authenticate_user!, only: [:show]

  def show
    @user = User.find_by_username(params[:username])

    if current_user.present?
      flights = Flight.belonging_to(@user.id).visible_to(current_user.id)
    else
      flights = Flight.belonging_to(@user.id).visible
    end

    @stats = FlightsHelper.generate_statistics(flights)
  end

  private

  def set_user
    @user = User.find_by_username(params[:username])
  end
end
