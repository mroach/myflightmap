class FixUtcColumnTypes < ActiveRecord::Migration
  def change
    change_column :flights, :depart_time_utc, :datetime
    change_column :flights, :arrive_time_utc, :datetime
  end
end
