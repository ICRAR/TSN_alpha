class Action < ActiveRecord::Base
  attr_accessible :action, :actor, :actionable,  :cost, :duration, :options, :queued_at, :queued_next_at, :run_at, :completed_at, :lock_version

  belongs_to :actor, polymorphic: true
  belongs_to :actionable, polymorphic: true

  serialize :options, Hash

  def self.states  #do not change order
    [:queued, :queued_next, :running, :completed]
  end

  validates_presence_of :action, :cost, :duration, :options, :state

  after_initialize :set_defaults
  def set_defaults
    if new_record?
      self.state ||= 0
      self.cost ||= 0
      self.duration ||= 0
      self.action ||= ''
      self.options ||= {}
    end
  end

  #queues up a new action
  def self.queue_new(actionable, actor, action_hash)
    new_action = self.new({
                              actor: actor,
                              actionable: actionable,
                              action: action_hash[:action],
                              options: action_hash[:options],
                              duration: action_hash[:duration],
                              cost: action_hash[:cost],
    })
    new_action.state = :queued
    if new_action.save
      self.queue_next(actionable)
    end
    new_action.reload
  end

  #estimated time to run atin UTC
  def run_at_time
    if is_queued_next?
      queued_next_at + duration
    elsif is_running?
      Time.now.utc
    else
      nil
    end
  end
  def time_remaining
    if is_queued_next? || is_running?
      (run_at_time - Time.now.utc )
    end
  end

  #queue the action
  def self.queue_next(actionable)
    #sets the next action as queued_next if its not already queued_next and inserts a delayed job

    insert_job = false
    queued_states = [
      self.states_hash[:queued],
      self.states_hash[:queued_next],
      self.states_hash[:running],
    ]
    all_queued_jobs = self.
        where{(actionable_type == actionable.class.to_s) & (actionable_id == actionable.id)}.
        where{state.in queued_states}
    next_action = all_queued_jobs.order{id.asc}.first
    #move to the next state and ensure that this is the only process that can do that. ,
    unless next_action.nil?
      begin
        if next_action.is_queued?
          insert_job = true
          next_action.state = :queued_next
          next_action.save
        end
      rescue ActiveRecord::StaleObjectError #if someone else beat us to it do nothing
        insert_job = false
      end
      if insert_job
        self.delay(run_at: next_action.run_at_time).background_job(next_action.id)
      end
    end
  end
  def self.background_job(action_id)
    action = self.find(action_id)
    action.run
  end
  #checks if the action has run or not yet
  def check_action
    (is_run?)
  end

  #check and run if not yet run but should be run now (+- 10 seconds)
  def check_and_run
    if is_queued_next?
      if time_remaining < 10
        run
      end
    end
  end
  #runs the action, we must ensure that this is the only process that is running the action
  def run
    can_run = false
    #if it is make action as running and continue
    #when a second process calls run, it will find that state as running and do nothing
    begin
      if self.is_queued_next?
        can_run = true
        self.state = :running
        self.save
      end
    rescue ActiveRecord::StaleObjectError
      can_run = false
    end
    if can_run
      #check that action is valid action type
      if self.actionable.actions_list.include? action
        #run action with options
        self.actionable.send("perform_#{action}".to_sym, self.options)
        #update the state
      else
        #raise some error

      end
      self.state = :completed
      self.save
      #queue the next action if there is one
      self.class.queue_next(actionable)
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
    self[state_at] = Time.now.utc if self.has_attribute? state_at
  end
  Action.states_hash.each do |k,v|
    define_method "is_#{k.to_s}?" do
      (state == v)
    end
  end
end
