class HomeController < ApplicationController
  skip_before_filter :authenticate_user!
  skip_after_filter :verify_authorized, only: [:about]

  def index
    @stats = FlightsHelper.generate_statistics(policy_scope(Flight))
  end

  def about
  end
end
