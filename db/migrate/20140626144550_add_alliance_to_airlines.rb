class AddAllianceToAirlines < ActiveRecord::Migration
  def change
    add_column :airlines, :alliance, :string
  end
end
