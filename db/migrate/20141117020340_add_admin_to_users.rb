class AddAdminToUsers < ActiveRecord::Migration
  def change
    add_column :users, :admin, :boolean, default: false
    User.find_by_username('mroach').update_attribute(:admin, true)
  end
end
