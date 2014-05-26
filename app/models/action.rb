class Action < ActiveRecord::Base
  attr_accessible :action, :cost, :duration, :options, :queued_at, :run_at, :completed_at, :state

  belongs_to :actors, polymorphic: true
  belongs_to :actionables, polymorphic: true

  def self.states  #do not change order
    [:queued, :queued_next, :running, :run]
  end

  validates_presence_of :action, :cost, :duration, :options, :state

  after_initialize :set_defaults
  def set_defaults
    if new_record?
      self.state ||= 0
      self.cost ||= 0
      self.duration ||= 0
      self.action ||= ''
      self.options ||= ''
    end
  end

  #queue the action
  def self.queue_next(actionable)
    #sets the next action as queued_next if its not already queued_next and inserts a delayed job
  end

  #checks if the action has run or not yet
  def check_action

  end

  #check and run if not yet run but should be run now (+- 10 seconds)
  def check_and_run

  end
  #runs the action, we must ensure that this is the only process that is running the action
  def run
    can_run = false
    #first lock the table and check if this action is still queued next
    #if it is make action as running and continue
    #when a second process calls run, it will find that state as running and do nothing
    self.class.transaction do
      lock!
      if is_queued_next?
        can_run = true
        state = :running
        save
      end
    end
    if can_run
      #check that action is valid action type
      if actionable.actions.include? action
        #run action with options
        actionable.send(action.to_sym, options)
        #update the state
        state = :run
        save
        #queue the next action if there is one
        self.class.queue_next(actionable)
      else
        #raise some error
      end
    end
  end

  #state management
  def self.states_hash
    h = {}
    states.each_with_index do |s,i|
      h[s] = i
    end
    h
  end
  def current_state
    self.class.states[state]
  end
  def state
    self[:state]
  end
  def state=(val)
    if val.is_a? Integer
      state_value = val
      state_name = self.class.states[val]
    elsif val.is_a? String
      state_value = self.class.states_hash[val.to_sym]
      state_name = val
    elsif val.is_a? Symbol
      state_value = self.class.states_hash[val]
      state_name = val.to_s
    else
      raise "Invalid value for defining state"
    end
    self[:state] = state_value
    state_at = "#{state_name}_at"
    self[state_at] = Time.now if self.has_attribute? state_at
  end
  Action.states_hash.each do |k,v|
    define_method "is_#{k.to_s}?" do
      (state == v)
    end
  end
end
