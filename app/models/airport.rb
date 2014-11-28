class Airport < ActiveRecord::Base
  include Formattable
  audited

  formattable "%{iata_code} %{name}"

  def current_time
    tz = TZInfo::Timezone.get(timezone)
    tz.now
  end

  def has_coordinates?
    !latitude.nil? && !longitude.nil? && latitude != 0 && longitude != 0
  end

  def coordinates
    [latitude, longitude]
  end

  def to_param
    iata_code
  end
end
