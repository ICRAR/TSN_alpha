class Alliance < ActiveRecord::Base
  attr_accessible :name, :as => [:default, :admin]
  attr_accessible :ranking, :credit, as: :admin

  scope :temp_credit, joins(:members => [:general_stats_item]).select("alliances.*, sum(general_stats_items.total_credit) as temp_credit, count(profiles.id) as total_members").group('alliances.id')
  scope :ranked, where("credit IS NOT NULL").order("credit DESC")

  has_one :leader, :class_name => 'Profile', :foreign_key => 'alliance_leader_id', :inverse_of => :alliance_leader
  has_many :members, :class_name => 'Profile'

  def self.for_show(id)
    where(:id => id).includes(:members=> [:general_stats_item]).includes(:leader).first
  end
end
