class AddPriorityToTrophy < ActiveRecord::Migration
  def change
    add_column :trophy_sets, :priority, :integer
    add_column :trophies, :priority, :integer
    add_column :profiles_trophies, :priority, :integer
  end
end
