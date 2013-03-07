class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :first_name
      t.string :second_name
      t.string :country
      t.belongs_to :user

      t.timestamps
    end
  end
end
