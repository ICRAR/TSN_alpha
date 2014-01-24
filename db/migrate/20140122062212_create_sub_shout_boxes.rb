class CreateSubShoutBoxes < ActiveRecord::Migration
  def change
    create_table :sub_shout_boxes do |t|
      t.integer :id
      t.string :msg

      t.timestamps
    end
  end
end
