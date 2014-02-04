class CreateChallengers < ActiveRecord::Migration
  def change
    create_table :challengers do |t|
      t.integer :score
      t.references  :challenge
      t.references  :entity, polymorphic: true
      t.datetime  :joined_at

      t.timestamps
    end
  end
end
