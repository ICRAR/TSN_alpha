#act as stateable is a very basic state machine system
#the current state is stored as a integer in the state column in the DB
#if a state_name_at column exists it will be set when that state is transitioned to.
#acts as expects the model to provide a states hash that maps integers to symbols
#acts as states should be called after states is defined
#the is no order control or validation to states.
#eg:
#def states  #do not change numbers only add new ones, order of numbers has no meaning
#  {
#      0 => :queued,
#      1 => :queued_next,
#      2 => :running,
#      3 => :completed,
#      4 => :failed,
#      5 => :instant,
#      6 => :instant_running
#  }
#end
#acts_as_stateable

module ActsAsStateable
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    def acts_as_stateable(options = {})
      include ActsAsStateable::LocalInstanceMethods
      states_hash.each do |k,v|
        define_method "is_#{k.to_s}?" do
          (state == v)
        end
      end
    end
  end

  module LocalInstanceMethods
    def states_hash
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
        state_name = self.states[val]
      elsif val.is_a? String
        state_value = self.states_hash[val.to_sym]
        state_name = val
      elsif val.is_a? Symbol
        state_value = self.states_hash[val]
        state_name = val.to_s
      else
        raise "Invalid value for defining state"
      end
      self[:state] = state_value
      state_at = "#{state_name}_at"
      self[state_at] = Time.now.utc if self.has_attribute? state_at
    end
  end
end


ActiveRecord::Base.send(:include, ActsAsStateable)