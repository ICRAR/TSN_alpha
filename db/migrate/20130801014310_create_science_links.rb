class CreateScienceLinks < ActiveRecord::Migration
  def change
    create_table :science_links do |t|
      t.string :name
      t.string :url
      t.belongs_to :science_portal


      t.timestamps
    end
    add_index :science_links, [:science_portal_id]
  end
end
