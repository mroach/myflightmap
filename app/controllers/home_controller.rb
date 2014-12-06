class HomeController < ApplicationController
  skip_before_filter :authenticate_user!

  def index
    @stats = FlightsHelper.generate_statistics(Flight.all.visible)
  end

  def about
  end
end
