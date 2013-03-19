class CreateNereusStatsItems < ActiveRecord::Migration
  def change
    create_table :nereus_stats_items do |t|
      t.integer :nereus_id
      t.integer :credit
      t.integer :daily_credit
      t.integer :rank
      t.belongs_to :general_stats_item

      t.timestamps
    end
  end
end
