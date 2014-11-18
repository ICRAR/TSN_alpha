class CreateGalaxyMosaics < ActiveRecord::Migration
  def change
    create_table :galaxy_mosaics do |t|
      t.boolean :display
      t.text :galaxy_hash
      t.text :options

      t.timestamps
    end
  end
end
