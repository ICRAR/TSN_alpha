class CreateTheskymapShoutBoxes < ActiveRecord::Migration
  def change
    create_table :theskymap_shout_boxes do |t|
      t.integer :id
      t.string :msg

      t.timestamps
    end
  end
end
