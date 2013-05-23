class CreateDailyAllianceCredit < ActiveRecord::Migration
  def change
    create_table :daily_alliance_credit do |t|
      t.integer :alliance_id
      t.integer :old_alliance_id
      t.integer :day
      t.integer :current_members
      t.integer :daily_credit
      t.integer :total_credit
      t.integer :rank
    end
  end
end
