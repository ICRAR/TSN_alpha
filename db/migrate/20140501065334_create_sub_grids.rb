class CreateSubGrids < ActiveRecord::Migration
  def change
    create_table :sub_grids do |t|
      t.integer :x
      t.integer :y
      t.integer :z
      t.string :name
      t.boolean :edge, default: false

      t.timestamps
    end
  end
end
