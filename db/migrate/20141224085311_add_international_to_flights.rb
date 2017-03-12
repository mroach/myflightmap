class AddInternationalToFlights < ActiveRecord::Migration
  def up
    # for some reason this is an issue when setting up a new database
    unless Flight.column_names.include? 'international'
      add_column :flights, :international, :boolean, null: false, default: false
    end

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
