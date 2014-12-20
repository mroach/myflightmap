class ConvertDurationToSeconds < ActiveRecord::Migration
  def up
    Flight.where("duration IS NOT NULL").update_all("duration = duration * 60")
  end

  def down
    Flight.where("duration IS NOT NULL").update_all("duration = duration / 60")
  end
end
