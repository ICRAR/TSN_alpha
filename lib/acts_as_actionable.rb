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