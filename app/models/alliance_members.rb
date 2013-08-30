class AllianceMembers < ActiveRecord::Base
  attr_accessible :join_date, :leave_credit, :leave_date, :start_credit, :as => :admin
  belongs_to :alliance
  belongs_to :profile

  def self.for_alliance_show(alliance_id)
    joins(:profile => [:general_stats_item]).
        select("alliance_members.*, (alliance_members.leave_credit-IFNULL(alliance_members.start_credit,0)) as credit_contributed, general_stats_items.rank as rank, general_stats_items.total_credit as credits").
        where("alliance_members.alliance_id = #{alliance_id}").order("credit_contributed DESC").includes(:profile => :user)
  end
  def total_credits
    leave_credit-start_credit
  end
  def days_in_alliance
    leave_day = leave_date ? leave_date : Time.now
     ((leave_day - join_date)/86400).round
  end

  def start_credit
    self[:start_credit].to_i
  end
  def leave_credit
    self[:leave_credit].to_i
  end

end
