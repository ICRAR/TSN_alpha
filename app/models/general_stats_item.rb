class GeneralStatsItem < ActiveRecord::Base
  attr_accessible :rank, :recent_avg_credit, :total_credit, :last_trophy_credit_value, as: :admin

  scope :has_credit, where("total_credit IS NOT NULL AND total_credit != 0").order("total_credit DESC")
  scope :no_credit,  where("total_credit IS NULL OR total_credit = 0")
  scope :for_update_credits, joins('LEFT JOIN "boinc_stats_items" ON "boinc_stats_items"."general_stats_item_id" = "general_stats_items"."id" LEFT JOIN "nereus_stats_items" ON "nereus_stats_items"."general_stats_item_id" = "general_stats_items"."id"').select("general_stats_items.id as id, general_stats_items.profile_id as profile_id, boinc_stats_items.credit as boinc_credit, nereus_stats_items.credit as nereus_credit")

  has_one :boinc_stats_item
  has_one :nereus_stats_item
  belongs_to :profile

  def credits_to_next_trophy
    total_credit = 0 if total_credit == nil
    tr = Trophy.next_trophy(total_credit)
    return tr.credits - total_credit
  end
end
