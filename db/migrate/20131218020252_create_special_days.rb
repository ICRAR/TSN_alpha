class CreateSpecialDays < ActiveRecord::Migration
  def change
    create_table :special_days do |t|
      t.string :name, null: false

      t.boolean :annual

      t.datetime :start_date
      t.datetime :end_date

      t.integer :start_day
      t.integer :start_month
      t.integer :end_day
      t.integer :end_month


      t.string  :url_code, null: false
      t.boolean :url_code_only
      t.string  :locale
      t.string  :features

      t.timestamps
    end
  end
end
