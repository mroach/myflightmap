class AddImageToIdentities < ActiveRecord::Migration
  def change
    add_column :identities, :image, :string
  end
end
