class HomeController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized, only: [:about]

  def index
    @stats = Stats.from_flights(policy_scope(Flight))
    @in_the_air = policy_scope(Flight).in_the_air.decorate
  end

  def about
  end
end
