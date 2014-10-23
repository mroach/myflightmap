class AddFlightRoleAndPurposeToFlights < ActiveRecord::Migration
  def change
    add_column :flights, :flight_role, :string
    add_column :flights, :purpose, :string
  end
end
