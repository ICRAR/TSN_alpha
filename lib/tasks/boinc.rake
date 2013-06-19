namespace :boinc do

  desc "loads data from external site"
  task :update_boinc => :environment do
    #start statsd batch
    statsd_batch = Statsd::Batch.new($statsd)
    bench_time = Benchmark.bm do |bench|


      bench.report('1') {
        #load xml file (note is gziped for size)
        remote_file = Zlib::GzipReader.new(open(APP_CONFIG['boinc_url']+APP_CONFIG['boinc_users_xml']))
        xml = Nokogiri::XML(remote_file)

        #start direct connection to DB for upsert
        connection = ActiveRecord::Base.connection.instance_variable_get(:@connection)
        table_name = :boinc_stats_items

        #total credit and total RAC
        total_credit = 0
        total_RAC = 0
        users_with_RAC = 0



        # Slice xml file into parts to speed up processing
        # Performance test varying slice size shoes that ~100 is appropriate
        # user     system      total        real
        #1 11.990000   0.760000  12.750000 ( 15.287818)
        #10  2.060000   0.380000   2.440000 (  4.183381)
        #100  0.960000   0.340000   1.300000 (  2.978770)
        #1000  0.800000   0.380000   1.180000 (  2.886246)
        xml.xpath('//user').each_slice(100) do |group|



          #start upsert batch for this slice
          Upsert.batch(connection,table_name) do |upsert|
            group.each do |user|
              #grab user data from xml file
              name, id, credit, RAC = user.xpath('./name','./id','./total_credit','./expavg_credit').map{|x| x.text.strip.to_i}
              total_credit += credit
              total_RAC += RAC
              users_with_RAC += (RAC > 10) ? 1 : 0
              #update DB object
              upsert.row({:boinc_id => id}, :credit => credit, :RAC => RAC, :updated_at => Time.now, :created_at => Time.now)
              #send to statsd
              statsd_batch.gauge("boinc.users.#{id}.credit",credit)
              statsd_batch.gauge("boinc.users.#{id}.rac",RAC)
            end
          end


        end
        statsd_batch.gauge("boinc.stat.total_credit",total_credit)
        statsd_batch.gauge("boinc.stat.total_rac",total_RAC)
        SiteStat.set("boinc_TFLOPS",(total_RAC*0.000005).round(2))
        statsd_batch.gauge("boinc.stat.total_users",xml.xpath('//user').size)
        statsd_batch.gauge("boinc.stat.active_users",users_with_RAC)
        statsd_batch.flush
      }
    end
    statsd_batch.gauge("boinc.stat.update_time",bench_time[0].total)
    statsd_batch.flush
  end
end