class CreateBoincStatsItems < ActiveRecord::Migration
  def change
    create_table :boinc_stats_items do |t|
      t.integer :boinc_id
      t.integer :credit
      t.integer :RAC
      t.integer :rank
      t.belongs_to :general_stats_item

      t.timestamps
    end
  end
end
