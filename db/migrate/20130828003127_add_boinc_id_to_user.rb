class AddBoincIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :boinc_id, :integer, :default => nil
  end
end
