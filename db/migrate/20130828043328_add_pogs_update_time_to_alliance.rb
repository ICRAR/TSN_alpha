class AddPogsUpdateTimeToAlliance < ActiveRecord::Migration
  def change
    add_column :alliances, :pogs_update_time, :integer
  end
end
