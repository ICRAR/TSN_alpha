class AddHiddenToChallenge < ActiveRecord::Migration
  def change
    add_column :challenges, :hidden, :boolean, null: false, default: false
  end
end
