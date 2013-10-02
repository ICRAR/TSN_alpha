class AddIsBoincToAlliances < ActiveRecord::Migration
  def change
    add_column :alliances, :is_boinc, :boolean, :default => false
    add_column :alliances, :pogs_team_id, :integer, :default => 0
  end
end
