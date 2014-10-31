class RenameUtcColumns < ActiveRecord::Migration
  def change
    remove_index :flights, name: 'index_flights_on_depart_date_utc_and_depart_time_utc'
    remove_index :flights, name: 'index_flights_on_arrive_date_utc_and_arrive_time_utc'
    remove_column :flights, :depart_date_utc
    remove_column :flights, :arrive_date_utc
    add_index :flights, :depart_time_utc
    add_index :flights, :arrive_time_utc
  end
end
