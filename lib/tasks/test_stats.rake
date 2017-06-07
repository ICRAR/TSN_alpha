namespace :test_stats do

  desc 'Sends a stat metric to the stats server'
  task :send => :environment do
    statsd_batch = Statsd::Batch.new
    statsd_batch.gauge('test.stat0', Time.now)
    statsd_batch.flush
  end

  desc 'Queries a stat metric from the stats server and displays it'
  task :get => :environment do

  end
end
