class AddHiddenToTrophies < ActiveRecord::Migration
  def change
    add_column :trophies, :hidden, :boolean
  end
end
