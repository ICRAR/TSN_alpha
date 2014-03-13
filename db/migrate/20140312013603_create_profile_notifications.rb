class CreateProfileNotifications < ActiveRecord::Migration
  def change
    create_table :profile_notifications do |t|
      t.belongs_to :profile
      t.string :subject
      t.text :body
      t.boolean :read
      t.boolean :aggregatable
      t.integer :aggregator_count
      t.text :aggregation_text
      t.belongs_to :notifier, polymorphic: true

      t.timestamps
    end
    add_index :profile_notifications, [:profile_id, :read, :aggregatable, :notifier_type, :notifier_id], :name => "profile_aggrigate_index"
    add_index :profile_notifications, [:profile_id, :read, :created_at], :name => "profile_read_index"
  end
end
