class CreateAirports < ActiveRecord::Migration
  def change
    create_table :airports do |t|
      t.string :iata_code, length: 3
      t.string :icao_code, length: 4
      t.string :name
      t.string :city
      t.string :country, length: 2
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.string :timezone
      t.string :description

      t.timestamps
    end

    add_index :airports, :iata_code, unique: true
  end
end
