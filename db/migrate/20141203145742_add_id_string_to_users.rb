class AddIdStringToUsers < ActiveRecord::Migration
  def change
    add_column :users, :id_hash, :string
    add_index :users, :id_hash
    User.all.each { |u| u.id_hash = User.hash_id(u.id); u.save! }
  end
end
