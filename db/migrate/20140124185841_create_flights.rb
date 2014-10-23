class CreateFlights < ActiveRecord::Migration
  def change
    create_table :flights do |t|
      t.references :user
      t.references :trip
      t.string :number, length: 10
      t.string :depart_airport, length: 3, null: false
      t.date :depart_date, null: false
      t.time :depart_time
      t.string :arrive_airport, length: 3, null: false
      t.date :arrive_date
      t.time :arrive_time
      t.integer :distance
      t.integer :duration
      t.references :airline
      t.string :airline_name
      t.string :aircraft_name
      t.string :seat
      t.string :seat_class
      t.string :seat_location

      t.timestamps
    end

    add_index :flights, :user_id
    add_index :flights, :trip_id
    add_index :flights, :depart_airport
    add_index :flights, :arrive_airport
    add_index :flights, :airline_name
  end
end
