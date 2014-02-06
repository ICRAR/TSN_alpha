class Challenger < ActiveRecord::Base
  attr_accessible :score, :start, :save_value, :rank, :challenge, :entity
  belongs_to :challenge, counter_cache: true
  belongs_to :entity, polymorphic: true

  has_many :metrics, as: :measurable, class_name: 'ChallengeData'

  scope :joins_alliance, joins('INNER JOIN alliances a ON a.id = challengers.entity_id').where{entity_type == 'Alliance'}
  scope :joins_profile, joins('INNER JOIN profiles p ON p.id = challengers.entity_id').where{entity_type == 'Profile'}
  scope :joins_profile_with_gsi, joins_profile.joins('INNER JOIN general_stats_item g ON g.profile_id = p.id')

  validates_presence_of :challenge, :entity_type, :entity_id

  validate :valid_entity
  def valid_entity
    errors.add(:entity, "Entity must be the same type as challenge.challenger_type") unless challenge.challenger_type == self.entity_type
    errors.add(:entity, "Entity has already joined this challenge") unless Challenger.where{(challenge_id == my{self.challenge_id}) & (entity_id == my{self.entity_id})}.first.nil?
  end

  def score_metric
    self.metrics.where{metric_key == 0}.order{datetime.asc}
  end

  def score_metric_json(name = "Score")
    {name: name, data: metric_json(score_metric)}
  end

  def rank_metric_json(name = "Rank")
    {name: name, data: metric_json(rank_metric)}
  end

  def rank_metric
    self.metrics.where{metric_key == 1}.order{datetime.asc}
  end

  def name
    e = entity
    if e.respond_to? :name
      out = e.name
    elsif e.respond_to? :title
      out = e.title
    else
      out = ''
    end
    out
  end

  private

  def metric_json(metrics)
    out = []
    metrics.each do |point|
      out << {x: point.datetime.to_i, y: point.value}
    end
    out
  end
end
