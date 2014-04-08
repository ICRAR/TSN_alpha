class GeneralStatsItem < ActiveRecord::Base
  attr_accessible :rank, :recent_avg_credit, :total_credit, :last_trophy_credit_value, :bonus_credit_ids, :power_user,  as: :admin

  scope :has_credit, where("total_credit IS NOT NULL AND total_credit != 0 AND power_user = false").order("total_credit DESC")
  scope :no_credit,  where("total_credit IS NULL OR total_credit = 0")
  scope :for_stats, select([:id,:rank, :recent_avg_credit, :total_credit, :profile_id])
  scope :for_update_credits, joins{boinc_stats_item.outer}.joins{nereus_stats_item.outer}.joins{bonus_credits.outer}.group{id}.
                select{id}.select{(ifnull(boinc_stats_item.credit,0) + ifnull(nereus_stats_item.credit,0) + ifnull(sum(bonus_credits.amount),0)).as 'total_credit'}.
                select{(ifnull(boinc_stats_item.RAC,0) + ifnull(nereus_stats_item.daily_credit,0)).as 'rac'}

  def self.update_all_credits
    sub_query = GeneralStatsItem.for_update_credits.to_sql
    main_query = GeneralStatsItem.joins("INNER JOIN (#{sub_query}) totals ON totals.id = `general_stats_items`.`id`")
    main_query.update_all(" `general_stats_items`.total_credit = totals.total_credit,
                           `general_stats_items`.recent_avg_credit = rac")
  end

  def self.update_ranks
    GeneralStatsItem.transaction do
      GeneralStatsItem.connection.execute 'SET @new_rank := 0'
      GeneralStatsItem.has_credit.order{total_credit.desc}.update_all('rank = @new_rank := @new_rank + 1')
    end
  end
  def self.ranks_from_profile_array(profile_ids)
    ranks_hash = {}
    GeneralStatsItem.transaction do
      GeneralStatsItem.connection.execute 'SET @new_rank := 0'
      ranks = GeneralStatsItem.has_credit.order{total_credit.desc}.
          where{profile_id.in profile_ids}.select(:profile_id).select('@new_rank := @new_rank + 1 as current_rank')
      ranks.each do |obj|
        ranks_hash[obj.profile_id] = obj.current_rank
      end
    end

    ranks_hash
  end
  has_one :boinc_stats_item
  has_one :nereus_stats_item
  belongs_to :profile
  has_many :bonus_credits, :dependent => :delete_all

  def credits_to_next_trophy
    self.total_credit = 0 if total_credit == nil
    tr = Trophy.next_trophy(total_credit, profile.old_site_user?)
    return tr ? tr.credits - total_credit : 0
  end
  def credits_from_last_trophy
    self.total_credit = 0 if total_credit == nil
    tr = Trophy.last_trophy(total_credit, profile.old_site_user?)
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
    self.total_credit = total_bonus_credit.to_i
    self.total_credit += nereus_stats_item.credit.to_i unless nereus_stats_item.nil?
    self.total_credit += boinc_stats_item.credit.to_i unless boinc_stats_item.nil?

    self.recent_avg_credit = 0
    self.recent_avg_credit += nereus_stats_item.daily_credit.to_i unless nereus_stats_item.nil?
    self.recent_avg_credit += boinc_stats_item.RAC.to_i unless boinc_stats_item.nil?
    self.save
  end

  def gflops
    self.recent_avg_credit ||= 0
    (self.recent_avg_credit.to_f * 0.005).round(2)

  end
end