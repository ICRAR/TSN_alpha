class CreateTrophies < ActiveRecord::Migration
  def change
    create_table :trophies do |t|
      t.string :title
      t.text :desc
      t.integer :credits
      t.attachment :image

      t.timestamps
    end
  end
end
