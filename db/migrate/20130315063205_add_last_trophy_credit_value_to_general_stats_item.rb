class AddLastTrophyCreditValueToGeneralStatsItem < ActiveRecord::Migration
  def change
    add_column :general_stats_items, :last_trophy_credit_value, :integer, :null => false, :default => 0
  end
end
