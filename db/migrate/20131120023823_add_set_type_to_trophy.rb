class AddSetTypeToTrophy < ActiveRecord::Migration
  def change
    add_column :trophies, :set_type, :string
  end
end
