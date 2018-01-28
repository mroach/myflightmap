class MapController < ApplicationController
  before_action :set_user
  skip_before_action :authenticate_user!, only: [:show]

  def show
    @user = User.find_by_username(params[:username])
    flights = policy_scope(Flight).belonging_to(@user.id).includes(:airline, :depart_airport_info, :arrive_airport_info)

    @stats = Stats.from_flights(flights)

    authorize :map, :show?
  end

  private

  def set_user
    @user = User.find_by_username!(params[:username])
  end
end
