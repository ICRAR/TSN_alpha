#workaround for globalize3
class Version < ActiveRecord::Base
  attr_accessible :locale, :as => [:default, :admin]
end