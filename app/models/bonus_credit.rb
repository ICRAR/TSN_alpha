class BonusCredit < ActiveRecord::Base
  attr_accessible :amount, :reason, :general_stats_item_id, as: [:default, :admin]
  belongs_to :general_stats_item

end
