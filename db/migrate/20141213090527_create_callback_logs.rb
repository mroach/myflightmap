class CreateCallbackLogs < ActiveRecord::Migration
  def up
    create_table :callback_logs do |t|
      t.string :provider, null: false
      t.string :url
      t.text :data
      t.string :target_type
      t.string :target_id
      t.string :status
      t.timestamps
    end
  end

  def down
    drop_table :callback_logs
  end
end
