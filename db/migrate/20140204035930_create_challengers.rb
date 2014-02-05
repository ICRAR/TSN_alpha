class CreateChallengers < ActiveRecord::Migration
  def change
    create_table :challengers do |t|
      t.integer :score
      t.integer :save_value
      t.integer :start
      t.integer :rank
      t.references  :challenge
      t.references  :entity, polymorphic: true
      t.datetime  :joined_at

      t.timestamps
    end
    add_index :challengers, [:challenge_id, :rank]
    add_index :challengers, [:entity_type, :entity_id]


  end
end
