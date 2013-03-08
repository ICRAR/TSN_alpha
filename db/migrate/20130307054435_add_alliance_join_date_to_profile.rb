class AddAllianceJoinDateToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :alliance_join_date, :datetime
  end
end
