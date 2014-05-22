class ChallengeData < ActiveRecord::Base
  attr_accessible :measurable_type, :measurable_id, :metric_key, :datetime, :value
  self.primary_keys = :measurable_type, :measurable_id, :metric_key, :datetime
  belongs_to :measurable, polymorphic: true

  def self.insert(select_relation)
    insert_sql = "INSERT INTO challenge_data (measurable_type, measurable_id, metric_key, datetime, value) #{select_relation.to_sql}"
    ChallengeData.connection.execute insert_sql
  end

  def self.delete_all_challenger(challenger)
    ChallengeData.where{measurable_type == 'Challenger'}.where{measurable_id == challenger.id}.delete_all
  end
end
