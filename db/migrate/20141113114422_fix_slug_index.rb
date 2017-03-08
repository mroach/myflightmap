class FixSlugIndex < ActiveRecord::Migration
  def change
    remove_index :trips, :slug
    add_index :trips, %i(user_id slug), unique: :true
  end
end
