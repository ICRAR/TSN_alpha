class CreateSiteStats < ActiveRecord::Migration
  def change
    create_table :site_stats do |t|
      t.string :name
      t.string :current_value
      t.string :previous_value
      t.timestamp :change_time

      t.timestamps
    end
  end
end
