class AddRacToAlliances < ActiveRecord::Migration
  def change
    add_column :alliances, :RAC, :integer
  end
end
