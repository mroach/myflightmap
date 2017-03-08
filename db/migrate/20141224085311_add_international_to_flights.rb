class AddInternationalToFlights < ActiveRecord::Migration
  def up
    add_column :flights, :international, :boolean, null: false, default: false

    Flight.joins(:depart_airport_info, :arrive_airport_info)
          .where('airports.country <> arrive_airport_infos_flights.country')
          .where('international = ?', false).each do |f|
      f.international = true
      f.audit_comment = 'Setting international flag'
      f.save!
    end

    add_index :flights, :international
  end

  def down
    remove_column :flights, :international
  end
end
