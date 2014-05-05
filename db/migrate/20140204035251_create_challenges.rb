class CreateChallenges < ActiveRecord::Migration
  def change
    create_table :challenges do |t|
      t.string :name
      t.text :desc
      t.datetime :start_date
      t.datetime :end_date
      t.boolean :invite_only
      t.boolean :join_while_running
      t.string :challenger_type #Alliance or Profile
      t.string :challenge_system #credit RAC ect
      t.string :project #All SourceFinder POGS ect
      t.integer :manager_id #All SourceFinder POGS ect
      t.boolean :started
      t.boolean :finished
      t.integer :challengers_count



      t.timestamps
    end
    add_index :challenges, [:start_date]
    add_index :challenges, [:end_date]
  end
end
