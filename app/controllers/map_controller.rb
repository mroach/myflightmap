require 'countries'

class MapController < ApplicationController

  before_action :get_user

  def show
    @flights = Flight.where(user_id: @user.id)

    # create a list of unique flight routes
    # for the purpose of creating a map, we have no use for return routes
    # by that I mean there's no need for CPH-SIN and SIN-CPH.
    # easy way to create a unique path, sort by airport, then unique them
    @routes = @flights
        .reject { |e| e.depart_airport_info.nil? || e.arrive_airport_info.nil? }
        .reject { |e| !e.depart_airport_info.has_coordinates? || !e.arrive_airport_info.has_coordinates? }
        .map do |f|
          info = [f.depart_airport_info, f.arrive_airport_info].sort
          { from: info[0], to: info[1] }
        end.uniq

    countries = @flights.reject { |e| e.depart_airport_info.nil? || e.arrive_airport_info.nil? }
        .map { |f| [f.depart_airport_info, f.arrive_airport_info] }
        .flatten
        .map { |a| a.country }

    @top_countries = countries
        .group_by { |c| c }
        .map { |k,v| { country: Country[k], flights: v.length} }
        .sort_by { |x| x[:flights] }
        .reverse
        .take(10)

    airports = @flights
        .reject { |e| e.depart_airport_info.nil? || e.arrive_airport_info.nil? }
        .map { |f| [f.depart_airport_info, f.arrive_airport_info] }
        .flatten

    @airports = airports
        .group_by { |f| f }
        .map { |k,v| { airport: k, flights: v.length } }
        .sort_by { |x| x[:flights] }
        .reverse

    @top_airports = @airports.take(10)

    @top_airlines = @flights.map { |f| f.airline }
        .group_by { |a| a }
        .map { |k,v| { airline: k, flights: v.length } }
        .sort_by { |x| x[:flights] }
        .reverse
        .take(10)

    @stats = {
      flights: @flights.length,
      countries: countries.uniq.length,
      airports: airports.uniq.length,
      airlines: @flights.map { |e| e.airline }.uniq.length,
      distance: @flights.map { |e| e[:distance] }.sum,
      duration: @flights.map { |e| e[:duration] }.sum
    }
  end

  private

  def get_user
    @user = User.find(params[:id] || current_user.id)
  end
end
