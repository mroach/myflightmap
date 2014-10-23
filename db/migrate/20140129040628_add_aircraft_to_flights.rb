class AddAircraftToFlights < ActiveRecord::Migration
  def change
    add_column :flights, :aircraft, :string
  end
end
