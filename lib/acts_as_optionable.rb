#act as optionable adds a few basic methods to a model to work with a options string stored in a the database
#the options string is called options
#the model must also provide a default_options method that returns a hash of default options.
module ActsAsOptionable
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    def acts_as_optionable(options = {})
      include ActsAsOptionable::LocalInstanceMethods
    end
  end

  module LocalInstanceMethods
    def options_without_default
      opt = self[:options] || '{}'
      begin
        opt_hash = JSON.parse opt
      rescue TypeError, JSON::ParserError
        opt_hash = {}
      end
    end
    def options
      self.options_default.merge options_without_default
    end
    def set_options(hash)
      new_hash = options_without_default.merge hash
      self.options =  new_hash.to_json
    end
    def reset_option(key)
      new_hash = options_without_default
      new_hash.delete key
      new_hash.delete key.to_s
      self.options =  new_hash.to_json
    end
  end
end


ActiveRecord::Base.send(:include, ActsAsOptionable)