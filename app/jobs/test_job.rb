class TestJob
  include Delayed::ScheduledJob
  run_every 1.minutes
  def self.display_name
    "custom_name"
  end
  def perform
    puts "hello world #{Time.now}"
    sleep 30
  end
end