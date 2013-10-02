class AddIndexToNotifications < ActiveRecord::Migration
  def change
    add_index :receipts, [:receiver_id,:is_read], :name => "index_receiver_id_is_read"
  end
end
