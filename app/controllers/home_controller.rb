class HomeController < ApplicationController
  skip_before_filter :authenticate_user!
  skip_after_filter :verify_authorized, only: [:about]

  def index
    @stats = Stats.from_flights(policy_scope(Flight))
    @in_the_air = policy_scope(Flight).in_the_air.decorate
  end

  def about
  end
end
