class AddAdventToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :advent_notify, :boolean
    add_column :profiles, :advent_last_day, :integer
  end
end
