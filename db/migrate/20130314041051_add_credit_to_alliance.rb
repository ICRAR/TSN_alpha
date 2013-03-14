class AddCreditToAlliance < ActiveRecord::Migration
  def change
    add_column :alliances, :credit, :integer
  end
end
