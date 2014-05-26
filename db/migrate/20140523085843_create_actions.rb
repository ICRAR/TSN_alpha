class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.string :action
      t.text :options
      t.integer :cost
      t.integer :duration
      t.integer :state
      t.datetime :queued_at
      t.datetime :queued_next_at
      t.datetime :run_at
      t.datetime :completed_at
      t.integer :lock_version, default: 0, null: false
      t.references :actor, polymorphic: true
      t.references :actionable, polymorphic: true

      t.timestamps
    end
    add_index :actions, [:actor_type, :actor_id, :created_at, :state], name: 'actor_index'
    add_index :actions, [:actionable_type, :actionable_id, :created_at, :state], name: 'actionable_index'
  end
end
