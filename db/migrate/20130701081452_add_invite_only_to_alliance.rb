class AddInviteOnlyToAlliance < ActiveRecord::Migration
  def change
    add_column :alliances, :invite_only, :boolean
  end
end
