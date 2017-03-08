class AirportPolicy < AdminEditorsPolicy
  def update_from_external?
    user && user.admin?
  end

  def search?
    true
  end
end
