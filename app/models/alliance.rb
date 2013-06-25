class Alliance < ActiveRecord::Base
  acts_as_taggable

  attr_accessible :name,:tags,:desc,:country, :old_id, :tag_list,  :as => [:default, :admin]
  attr_accessible :leader_id, :member_ids, as: :admin

  scope :temp_credit, joins(:member_items).select("alliances.*, sum(alliance_members.leave_credit-alliance_members.start_credit) as temp_credit").group('alliances.id')
  scope :temp_rac, joins(:members => [:general_stats_item]).select("alliances.*, sum(general_stats_items.recent_avg_credit) as temp_rac, count(general_stats_items.id) as total_members").group('alliances.id')
  scope :ranked, where("credit IS NOT NULL").order("credit DESC")
  scope :for_leaderboard, where("credit IS NOT NULL").includes(:leader)
  scope :for_leaderboard_small, where("credit IS NOT NULL")

  has_one :leader, :foreign_key => "alliance_leader_id", :class_name => 'Profile', :inverse_of => :alliance_leader
  has_many :member_items, :class_name => 'AllianceMembers', :dependent => :destroy
  has_many :members, :class_name => 'Profile', :inverse_of => :alliance
  has_many :invites, :class_name => "AllianceInvite", :inverse_of => :alliance, :dependent => :destroy

  def self.for_show(id)
    where(:id => id).includes(:leader).first
  end

  def leader_id
    self.leader.try :id
  end
  def leader_id=(id)
    self.leader = Profile.find_by_id(id)
  end

  rails_admin do
    configure :block_grid_associations do
      visible(false)
    end
  end
  def for_json
    result = Hash.new
    result[:id] = id
    result[:name] = name
    result[:rank] = ranking
    result[:leader] = leader.try :for_json_basic
    return  result
  end


  include Tire::Model::Search
  include Tire::Model::Callbacks

  mapping do
    indexes :name, analyzer: 'snowball', tokenizer: 'nGram'
    indexes :tags, :as => 'tag_list.to_s', analyzer: 'snowball', tokenizer: 'nGram'
  end

  def self.search(query,page,per_page)
    tire.search(:page => (page || 1), :per_page => per_page, :load => {:include => 'leader'}) do
      query do
        boolean(:minimum_number_should_match => 1) do
          should {fuzzy :name, query}
          should {match :name, query}
          should {prefix :name, query}
          should {fuzzy :tags, query}
          should {match :tags, query}
          should {prefix :tags, query}
        end
      end
    end
  end

end
