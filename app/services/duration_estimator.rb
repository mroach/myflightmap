require 'geo'

class DurationEstimator
  attr_accessor :speed, :overhead

  def initialize(params = {})
    # To estimate the time spent covering a distance you need to decide on an
    # average speed. Use 885km/h (550 sm/h) which is a pretty standard rate
    @speed = params.fetch(:speed, 885)

    # Obviously a plane doesn't fly at 885km/h from gate to gate. We need to
    # add on some "overhead" time spent on the slower ascents an descents
    # 40 minutes is about right. 20 minutes for takeoff and landing.
    @overhead = params.fetch(:overhead, 40 * 60)
  end

  # Return the estimated travel time between two coordinates
  # 1) Calculate the distnace in km between the two coordinates
  # 2) Determine time it'd take to travel that distance at the given @speed
  # 3) Add on the @overhead to account for slower speeds during takeoff and landing
  def estimate(point_a, point_b)
    distance = Geo.distance_between(point_a, point_b).to_i
    distance * 3600 / @speed + @overhead
  end
end
