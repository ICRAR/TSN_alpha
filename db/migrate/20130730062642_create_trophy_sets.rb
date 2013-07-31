class CreateTrophySets < ActiveRecord::Migration
  def change
    create_table :trophy_sets do |t|
      t.string :name
      t.string :set_type
      t.boolean :main, :null => false, :default => false

      t.timestamps
    end
    add_column :trophies, :trophy_set_id, :integer
  end
end
