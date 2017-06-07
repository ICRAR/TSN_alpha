require 'influxdb'

namespace :test_stats do

  desc 'Sends a stat metric to the stats server'
  task :send => :environment do
    statsd_batch = Statsd::Batch.new($statsd)
    statsd_batch.gauge('test.stat0', Time.now.to_f)
    statsd_batch.flush
  end

  desc 'Queries a stat metric from the stats server and displays it'
  task :get => :environment do
    influxdb = InfluxDB::Client.new host: '52.23.237.154', database: 'tsn-stats'

    influxdb.query 'select * from TSN_dev_test_stat_0' do |name, tags, points|
      printf "%s [ %p ]\n", name, tags
      points.each do |pt|
        printf "  -> %p\n", pt
      end
    end
  end
end
