class GeneralStatsItem < ActiveRecord::Base
  attr_accessible :rank, :recent_avg_credit, :total_credit, :last_trophy_credit_value, :bonus_credit_ids, :power_user,  as: :admin

  scope :has_credit, where("total_credit IS NOT NULL AND total_credit != 0 AND power_user = false").order("total_credit DESC")
  scope :no_credit,  where("total_credit IS NULL OR total_credit = 0")
  scope :for_update_credits, joins('LEFT JOIN boinc_stats_items ON boinc_stats_items.general_stats_item_id = general_stats_items.id
                                    LEFT JOIN nereus_stats_items ON nereus_stats_items.general_stats_item_id = general_stats_items.id').
                                   select("general_stats_items.id as id, general_stats_items.profile_id as profile_id,
                                          boinc_stats_items.credit as boinc_credit, boinc_stats_items.`RAC` as boinc_daily, nereus_stats_items.credit as nereus_credit,
                                          nereus_stats_items.daily_credit as nereus_daily").
                                   includes(:bonus_credits)

  has_one :boinc_stats_item
  has_one :nereus_stats_item
  belongs_to :profile
  has_many :bonus_credits

  def credits_to_next_trophy
    self.total_credit = 0 if total_credit == nil
    tr = Trophy.next_trophy(total_credit)
    return tr ? tr.credits - total_credit : 0
  end
  def credits_from_last_trophy
    self.total_credit = 0 if total_credit == nil
    tr = Trophy.last_trophy(total_credit)
    return tr ? total_credit-tr.credits : 0
  end

  def total_bonus_credit
    total = 0
    bonus_credits.each do |c|
      total += c.amount
    end
    total
  end

  def update_credit
    self.total_credit = total_bonus_credit
    self.total_credit += nereus_stats_item.credit unless nereus_stats_item.nil?
    self.total_credit += boinc_stats_item.credit unless boinc_stats_item.nil?
    self.save
  end

  def gflops
    recent_avg_credit ||= 0
    recent_avg_credit.to_f * 0.005
  end
end