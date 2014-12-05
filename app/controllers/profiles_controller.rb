class ProfilesController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:show]
  before_action :set_user, only: [:show, :map]
  before_action :reject_non_admin!, only: [:index]

  def index
    @users = User.all.order(:created_at)
  end

  def show
    @user = User.find_by_username(params[:username])
    @trips = @user.trips.visible_to(current_user).recent.limit(5)
    @flights = @user.flights.visible_to(current_user).recent.completed.limit(5)
    @show_controls = user_signed_in? && @user.id == current_user.id
  end

  private

  def set_user
    @user = User.find_by_username!(params[:username])
  end
end
