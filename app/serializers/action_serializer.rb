class ActionSerializer < ActiveModel::Serializer
  attributes :id, :current_state, :action, :time_remaining, :valid, :options,
             :run_at_time, :queued_at_time
  embed :ids
  has_one :actionable, polymorphic: true
  has_one :actor, polymorphic: true
  def valid
    object.valid?
  end
  def options
    object.options
  end
  def run_at_time
    object.run_at_time.to_i
  end
  def queued_at_time
    object.queued_at.to_i
  end

end