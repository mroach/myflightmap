class ProfilesController < ApplicationController
  skip_before_filter :authenticate_user!, only: [:show]
  before_action :set_user, only: [:show, :map]

  def index
    render status: 404 unless current_user.present? && current_user.admin?
    @users = User.all.order(:created_at)
  end

  def show
    @user = User.find_by_username(params[:username])
    @trips = @user.trips.visible_to(current_user).recent.limit(5)
    @flights = @user.flights.visible_to(current_user).recent.completed.limit(5)
  end

  private

  def set_user
    @user = User.find_by_username!(params[:username])
  end
end
