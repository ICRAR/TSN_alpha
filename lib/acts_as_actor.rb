module ActsAsActor
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    def acts_as_actor(options = {})
      include ActsAsActor::LocalInstanceMethods
      has_many :actions, as: :actor, class_name: 'Action'
    end
  end

  module LocalInstanceMethods

  end
end

ActiveRecord::Base.send(:include, ActsAsActor)