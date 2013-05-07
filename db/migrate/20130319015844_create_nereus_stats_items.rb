class CreateNereusStatsItems < ActiveRecord::Migration
  def change
    create_table :nereus_stats_items do |t|
      t.integer :nereus_id
      t.integer :credit, :default => 0
      t.integer :daily_credit, :default => 0
      t.integer :rank, :default => 0
      t.belongs_to :general_stats_item

      t.timestamps
    end
  end
end
