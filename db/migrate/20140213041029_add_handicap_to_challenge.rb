class AddHandicapToChallenge < ActiveRecord::Migration
  def change
    add_column :challengers, :handicap, :float, null: false, default: 1
    add_column :challenges, :handicap_type, :string
  end
end
