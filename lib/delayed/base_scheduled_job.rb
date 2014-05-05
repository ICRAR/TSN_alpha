module Delayed
  class BaseScheduledJob < Struct.new(:options)
    include Delayed::ScheduledJob
    def options
      self[:options] || {}
    end
  end
end