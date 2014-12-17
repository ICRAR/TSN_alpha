module ActsAsActionable
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    def acts_as_actionable(options = {})
      include ActsAsActionable::LocalInstanceMethods
      before_destroy :refund_all_pending_actions
      has_many :actions, as: :actionable, class_name: 'Action'
    end
  end

  module LocalInstanceMethods
    # an action hash should take the form:
    # move_1_2_3: {                     #an identifying name
    #     action: 'move',               #action method to be called
    #     name: 'move to Quadrant 1',   #display name
    #     cost: 10,                     #cost to perform
    #     duration: 300, #in seconds    #delay before the action takes place
    #     options: {x: 1, y: 2,z: 3},   #any options to be passed to the action method
    #     allowed: true,                #Can the action be performed at the moment
    #     display: true                 #Should the action be displayed in the GUI, in the new action selection
    #     instant: false                #If instant is true then run the action now skipping the action queue
    #     skippable: true                #Marks the action as skippable with the use of special credit.
    # }
    def action_defaults
    {
      display: true,
      skippable: true,
      instant: false
    }
    end
    def perform_action(actor, action_name)
      an = action_name.to_sym
      action_hash = actions_available(actor)[an]
      return 'failed' if action_hash.nil? || action_hash[:allowed] == false
      #deduct the cost from the actor
      actor.deduct_currency(action_hash[:cost])

      if action_hash[:instant] == true
        #if action is instant run now instead of queuing
        Action.instant_action(self, actor, action_hash)
      else
        #add the action the queue
        Action.queue_new(self, actor, action_hash)
      end
    end
    def actions_available(actor)
      actions_all = self.all_actions(actor)
      actors_current_bank = actor.currency_available
      actions_all.each do |action, attributes|
        actions_all[action].reverse_merge! self.action_defaults
        actions_all[action][:allowed] = false if actions_all[action][:cost] > actors_current_bank
      end
      actions_all
    end
    def actions_available_array(actor)
      array_out = []
      actions_available(actor).each do |key,value|
        array_out << value.merge({action_name: key, action_name_href: "##{key}"})
      end
      array_out
    end
    def all_actions(actor)
      actions_all = {}
      actions_list.each do |action|
        actions_all.merge! self.send("#{action}_options".to_sym,actor)
      end
      actions_all
    end
    def current_action
      actions.current_action.first
    end
    def refund_all_pending_actions
      Action.refund_all_pending_actions(self,self.default_actor)
    end
  end
end


ActiveRecord::Base.send(:include, ActsAsActionable)