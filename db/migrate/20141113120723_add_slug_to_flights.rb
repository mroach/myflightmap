class AddSlugToFlights < ActiveRecord::Migration
  def change
    add_column :flights, :slug, :string
    add_index :flights, [:user_id, :slug], unique: true
    Flight.find_each(&:save)
  end
end
