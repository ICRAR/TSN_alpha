class CreateChallenges < ActiveRecord::Migration
  def change
    create_table :challenges do |t|
      t.string :name
      t.text :desc
      t.datetime :start
      t.datetime :end
      t.boolean :invite_only
      t.string :type #Alliance or Profile
      t.string :system #credit RAC ect
      t.string :project #All SourceFinder POGS ect
      t.integer :manager_id #All SourceFinder POGS ect
      t.boolean :running
      t.boolean :finished



      t.timestamps
    end
  end
end
