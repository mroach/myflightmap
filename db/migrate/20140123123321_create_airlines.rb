class CreateAirlines < ActiveRecord::Migration
  def change
    create_table :airlines do |t|
      t.string :iata_code, length: 2
      t.string :icao_code, length: 3
      t.string :name
      t.string :country, length: 2

      t.timestamps
    end

    add_index :airlines, :iata_code, unique: true
  end
end
