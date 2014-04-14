class CreateTimelineEntries < ActiveRecord::Migration
  def change
    create_table :timeline_entries do |t|
      t.string :subject
      t.text :more
      t.string :subject_aggregate
      t.text :more_aggregate
      t.string :aggregate_type
      t.string :aggregate_type_2
      t.string :aggregate_text
      t.datetime :posted_at
      t.references  :timelineable, polymorphic: true

      t.timestamps
    end
    add_index :timeline_entries, ["timelineable_id", "timelineable_type", "posted_at","aggregate_type","aggregate_type_2"], name: "agg_timeline_index"
  end
end
