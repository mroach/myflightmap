class ProfilesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]

  def index
    authorize :user, :index?
    @users = policy_scope(User).order('COALESCE(last_sign_in_at, created_at) DESC').decorate
  end

  def show
    @user = User.find_by_username!(params[:username]).decorate
    @trips = policy_scope(Trip).belonging_to(@user.id).recent.limit(5)
    @flights = policy_scope(Flight).belonging_to(@user).recent.completed.limit(5)
    authorize @user
  end
end
