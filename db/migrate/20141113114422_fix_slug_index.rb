class FixSlugIndex < ActiveRecord::Migration
  def change
    remove_index :trips, :slug
    add_index :trips, [:user_id, :slug], unique: :true
  end
end
