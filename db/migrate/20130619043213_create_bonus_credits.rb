class CreateBonusCredits < ActiveRecord::Migration
  def change
    create_table :bonus_credits do |t|
      t.integer :amount
      t.text :reason
      t.belongs_to :general_stats_item
      t.timestamps
    end
  end
end
