class AddOldIdToAlliance < ActiveRecord::Migration
  def change
    add_column :alliances, :old_id, :integer
  end
end
