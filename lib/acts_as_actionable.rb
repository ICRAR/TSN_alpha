module ActsAsActionable
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    def acts_as_actionable(options = {})
      include ActsAsActionable::LocalInstanceMethods
    end
  end

  module LocalInstanceMethods
    # an action hash should take the form:
    # move_1_2_3: {
    #     action: 'move',
    #     name: 'move to Quadrant 1',
    #     cost: 10,
    #     duration: 300, #in seconds
    #     options: {x: 1, y: 2,z: 3},
    #     allowed: true,
    # }
    def perform_action(actor, action_name)
      action_hash = actions_available(actor)[action_name]
      return false if action_hash.nil? || action_hash[:allowed] == false
      Action.queue_new(self, actor, action_hash)
    end
    def actions_available(actor)
      actions_all = self.all_actions(actor)
      actors_current_bank = actor.currency_available
      actions_all.each do |action, attributes|
        actions_all[action][:allowed] = false if actions_all[action][:cost] > actors_current_bank
      end
      actions_all
    end
    def all_actions(actor)
      actions_all = {}
      actions.each do |action|
        actions_all.merge! self.send("#{action}_options".to_sym,actor)
      end
      actions_all
    end
  end
end


ActiveRecord::Base.send(:include, ActsAsActionable)