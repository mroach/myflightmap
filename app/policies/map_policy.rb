# "Headless" security policy for maps which don't have underlying models
# For now maps are available to anyone
class MapPolicy < Struct.new(:user, :map)
  def show?
    true
  end
end
