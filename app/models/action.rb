class Action < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :action, :actor, :actionable,  :cost, :duration, :options, :queued_at, :queued_next_at, :run_at, :completed_at, :lock_version

  belongs_to :actor, polymorphic: true
  belongs_to :actionable, polymorphic: true
  #returns and ActiveRecord relation containing the current action and all sibling actions that are queued_next
  #used to update the GUI when an action completes and other actions potentially change state
  def self_and_other_queued
    sh = self.class.states_hash
    interested_states = [sh[:queued_next],sh[:running]]
    self.class.where{(actionable_id == my{self.actionable_id}) & (actionable_type == my{self.actionable_type})}.
      where{(id == my{self.id}) |  (state == my{sh[:queued_next]})}
  end

  serialize :options, Hash

  def self.states  #do not change numbers only add new ones, order of numbers has no meaning
    {
        0 => :queued,
        1 => :queued_next,
        2 => :running,
        3 => :completed,
        4 => :failed,
        5 => :instant,
        6 => :instant_running
    }
  end

  scope :current_action, where{state.in [1,2]}
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
  #Runs a new action without queuing it.
  def self.instant_action(actionable, actor, action_hash)
    new_action = self.new({
                              actor: actor,
                              actionable: actionable,
                              action: action_hash[:action],
                              options: action_hash[:options],
                              duration: 0,
                              cost: action_hash[:cost],
    })
    new_action.state = :instant
    if new_action.save
      new_action.run_instant
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
  def special_cost
    is_queued_next? ? ((time_remaining / 60).ceil) : 0
  end
  #queue the action
  def self.queue_next(actionable)
    #sets the next action as queued_next if its not already queued_next and inserts a delayed job

    insert_job = false
    class_name = self
    queued_states = [
        class_name.states_hash[:queued],
        class_name.states_hash[:queued_next],
        class_name.states_hash[:running],
    ]
    all_queued_jobs = class_name.
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
        class_name.delay(run_at: next_action.run_at_time).background_job(next_action.id)
      end
    end
  end
  def self.background_job(action_id)
    begin
      action = self.find(action_id)
      action.run
    rescue ActiveRecord::RecordNotFound
      #do nothing this action no longer exists
    end
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
  #uses special currency to force an upcoming action to run now.
  def run_special
    save_cost = special_cost
    if save_cost > 0 && save_cost <= self.actor.currency_available_special
      if self.run
        self.actor.deduct_currency_special save_cost
      end
    end
  end

  #runs the action skipping the queue system
  def run_instant
    can_run = false
    begin
      #check that action is an instant action
      if self.is_instant?
        can_run = true
        self.state = :instant_running
        self.save
      end
    rescue ActiveRecord::StaleObjectError
      can_run = false
    end
    if can_run
      self.run_action
      self.save
    end
    can_run
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
      self.run_action
      self.save
      #queue the next action if there is one
      self.class.queue_next(actionable)
    end
    can_run
  end
  #performs action method on actionable if this fails refund the currency
  def run_action
    #check that actionable still exists
    if self.actionable
      #check that action is valid action type
      if self.actionable.actions_list.include?(action)
        #run action with options
        begin
          action_success = self.actionable.send("perform_#{action}".to_sym, self.options)
        rescue Exception => e
          self.state = :failed
          self.actor.refund_currency(self.cost)
          self.save
          self.class.queue_next(actionable)
          raise e
        end
        #update the state
        if action_success
          self.state = :completed
        else
          #reverse the 'payment' and cancel the action
          self.state = :failed
          self.actor.refund_currency(self.cost)
        end
      else
        #reverse the 'payment' and cancel the action
        self.state = :failed
        self.actor.refund_currency(self.cost)
      end
    else
      #reverse the 'payment' and delete the action
      self.actor.refund_currency(self.cost)
      self.destroy
    end
  end
  #state management
  def self.states_hash
    states.invert
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

  def self.refund_all_pending_actions(actionable,actor)
    #take all pending actions and sum total currency
    queued_states = [
        self.states_hash[:queued],
        self.states_hash[:queued_next],
    ]
    total_refund = actionable.actions.where{state.in queued_states}.sum(:cost)
    actionable.actions.destroy
  end
end
