class RemoveInternationalFromAirportDescriptions < ActiveRecord::Migration
  def change
    Airport.update_all("description = TRIM(BOTH FROM REPLACE(description, 'International', ''))")
  end
end
