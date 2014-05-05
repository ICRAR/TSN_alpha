class AddLogToAllianceMembers < ActiveRecord::Migration
  def change
    add_column :alliance_members, :log, :text
  end
end
