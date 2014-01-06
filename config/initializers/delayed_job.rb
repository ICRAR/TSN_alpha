Delayed::Job.class_eval do
  attr_accessible :run_at, :as => [:default, :admin]
end