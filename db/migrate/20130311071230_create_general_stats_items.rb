class CreateGeneralStatsItems < ActiveRecord::Migration
  def change
    create_table :general_stats_items do |t|
      t.integer :total_credit
      t.integer :recent_avg_credit
      t.integer :rank
      t.belongs_to :profile

      t.timestamps
    end
  end
end
