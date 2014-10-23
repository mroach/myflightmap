class AddAttachmentLogoToAirlines < ActiveRecord::Migration
  def self.up
    change_table :airlines do |t|
      t.attachment :logo
    end
  end

  def self.down
    drop_attached_file :airlines, :logo
  end
end
