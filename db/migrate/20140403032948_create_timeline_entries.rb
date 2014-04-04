class CreateTimelineEntries < ActiveRecord::Migration
  def change
    create_table :timeline_entries do |t|
      t.string :subject
      t.text :more
      t.string :subject_aggregate
      t.text :more_aggregate
      t.string :aggregate_type
      t.string :aggregate_text
      t.datetime :posted_at
      t.belongs_to :profile

      t.timestamps
    end
    add_index :timeline_entries, ["profile_id", "posted_at","aggregate_type"], name: "agg_timeline_index"
  end
end
