class CreateSciencePortals < ActiveRecord::Migration
  def change
    create_table :science_portals do |t|
      t.string :name
      t.boolean :public
      t.text :desc

      t.timestamps
    end
    add_index :id, [:id]
  end

end
