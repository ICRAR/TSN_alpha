class CreateNews < ActiveRecord::Migration
  def change
    create_table :news do |t|
      t.string :title
      t.text :short
      t.text :long
      t.boolean :published
      t.datetime :published_time

      t.timestamps
    end
  end
end
