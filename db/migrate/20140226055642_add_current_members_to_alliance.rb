class AddCurrentMembersToAlliance < ActiveRecord::Migration
  def change
    add_column :alliances, :current_members, :integer
  end
end
