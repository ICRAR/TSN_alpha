class CreateChallengeData < ActiveRecord::Migration
  def change
    create_table :challenge_data, {:id => false}  do |t|
      t.belongs_to  :measurable, polymorphic: true
      t.integer     :metric_key, null: false, default: 0
      t.integer     :value, null: false
      t.datetime    :datetime, null: false

    end
    add_index :challenge_data, [:measurable_type, :measurable_id, :metric_key, :datetime], unique: true, name: "challenge_data_primary_index"
  end
end
