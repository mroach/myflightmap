class RenameFlightNumberToFlightCode < ActiveRecord::Migration
  def change
    rename_column :flights, :number, :flight_code
  end
end
