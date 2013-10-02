class TestJob
  include Delayed::ScheduledJob
  run_every 1.minutes
  def perform
    puts "hello world #{Time.now}"
    sleep 30
  end
end