class AddPublicToFlightsAndTrips < ActiveRecord::Migration
  def change
    add_column :flights, :is_public, :boolean, default: true
    add_column :trips, :is_public, :boolean, default: true
  end
end
