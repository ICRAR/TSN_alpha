class TrophiesJob
  include Delayed::ScheduledJob
  run_every 1.hour
  def perform
    @statsd_batch = Statsd::Batch.new($statsd)
    bench_time = Benchmark.bm do |bench|
      bench.report('update trophies') {
        #load all trophies
        trophies = Trophy.all_credit_active.order("credits ASC")
        Trophy.handout_by_credit(trophies)
      }
      @statsd_batch.flush
    end
  end
end