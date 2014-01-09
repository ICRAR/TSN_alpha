class AddStartOfChallengeToGeneralStatsItem < ActiveRecord::Migration
  def change
    add_column :general_stats_items, :start_of_challenge, :integer
  end
end
