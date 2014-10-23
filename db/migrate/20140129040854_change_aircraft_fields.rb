class ChangeAircraftFields < ActiveRecord::Migration
  def change
    remove_column :flights, :aircraft
    add_column :flights, :aircraft_type, :string
    add_column :flights, :aircraft_registration, :string
  end
end
