class CreateTrips < ActiveRecord::Migration
  def change
    create_table :trips do |t|
      t.references :user
      t.string :name
      t.string :purpose
      t.integer :flight_count
      t.date :begin_date
      t.date :end_date

      t.timestamps
    end

    add_index :trips, :user_id
  end
end
