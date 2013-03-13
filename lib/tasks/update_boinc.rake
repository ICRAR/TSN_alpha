namespace :boinc do

  desc "loads data from external site"
  task :update_stats => :environment do

    Benchmark.bm do |bench|
      bench.report('1') {
        #load xml file (note is gziped for size)
        remote_file = Zlib::GzipReader.new(open(APP_CONFIG['boinc_stats_xml_url']))
        xml = Nokogiri::XML(remote_file)

        #start direct connection to DB for upsert
        connection = PG.connect(:dbname => Rails.configuration.database_configuration[Rails.env]["database"])
        table_name = :boinc_stats_items

        # Slice xml file into parts to speed up processing
        # Performance test varying slice size shoes that ~100 is appropriate
        # user     system      total        real
        #1 11.990000   0.760000  12.750000 ( 15.287818)
        #10  2.060000   0.380000   2.440000 (  4.183381)
        #100  0.960000   0.340000   1.300000 (  2.978770)
        #1000  0.800000   0.380000   1.180000 (  2.886246)
        xml.xpath('//user').each_slice(100) do |group|
          #start statsd batch
          statsd_batch = Statsd::Batch.new($statsd)

          #start upsert batch for this slice
          Upsert.batch(connection,table_name) do |upsert|
            group.each do |user|
              #grab user data from xml file
              name, id, credit, RAC = user.xpath('./name','./id','./total_credit','./expavg_credit').map{|x| x.text.strip}
              #update DB object
              upsert.row({:boinc_id => id}, :credit => credit.to_i, :RAC => RAC.to_i, :created_at => Time.now, :updated_at => Time.now)
              #send to statsd
              statsd_batch.gauge("boinc.#{id}.credit",credit.to_i)
              statsd_batch.gauge("boinc.#{id}.rac",RAC.to_i)
            end
          end
          statsd_batch.flush
        end

      }


    end
  end
end