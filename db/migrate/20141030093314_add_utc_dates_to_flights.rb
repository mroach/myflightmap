class AddUtcDatesToFlights < ActiveRecord::Migration
  def change
    add_column :flights, :depart_date_utc, :date
    add_column :flights, :depart_time_utc, :time
    add_column :flights, :arrive_date_utc, :date
    add_column :flights, :arrive_time_utc, :time

    add_index :flights, %i(depart_date_utc depart_time_utc)
    add_index :flights, %i(arrive_date_utc arrive_time_utc)
  end
end
