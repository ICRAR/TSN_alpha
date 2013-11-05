#### ALLIANCE_DUP_CODE ###
class AddDuplicateIdToAlliance < ActiveRecord::Migration
  def change
    add_column :alliances, :duplicate_id, :integer
  end
end
