class StatsAlliancesJob
  include Delayed::ScheduledJob
  run_every 1.minutes
  def perform
    statsd_batch = Statsd::Batch.new($statsd)
    bench_time = Benchmark.bm do |bench|
      bench.report('update credit alliance member items') {
        connection = ActiveRecord::Base.connection.instance_variable_get(:@connection)
        connection.query("UPDATE alliance_members
                          INNER JOIN general_stats_items ON general_stats_items.profile_id = alliance_members.profile_id
                          SET alliance_members.leave_credit = general_stats_items.total_credit
                          WHERE alliance_members.leave_date IS NULL")
      }

      bench.report('update credit alliance') {
        connection = ActiveRecord::Base.connection.instance_variable_get(:@connection)
        table_name = :alliances

        alliances_credit = Alliance.temp_credit
        alliances_rac_total = Alliance.temp_rac
        Upsert.batch(connection,table_name) do |upsert|
          alliances_rac_total.each do |alliance|
            upsert.row({:id => alliance.id},:RAC => alliance.temp_rac, :updated_at => Time.now, :created_at => Time.now)
            statsd_batch.gauge("general.alliance.#{GraphitePathModule.path_for_stats(alliance.id)}.daily_credit",alliance.temp_rac)
            statsd_batch.gauge("general.alliance.#{GraphitePathModule.path_for_stats(alliance.id)}.current_members",alliance.total_members)
          end
          alliances_credit.each do |alliance|
            credit = alliance.temp_credit
            upsert.row({:id => alliance.id}, :credit => credit, :updated_at => Time.now, :created_at => Time.now)
            statsd_batch.gauge("general.alliance.#{GraphitePathModule.path_for_stats(alliance.id)}.total_credit",credit)
          end
        end
      }

      bench.report('update rank alliance') {
        connection = ActiveRecord::Base.connection.instance_variable_get(:@connection)
        table_name = :alliances
        rank = 1
        alliances = Alliance.ranked
        Upsert.batch(connection,table_name) do |upsert|
          alliances.each do |alliance|
            upsert.row({:id => alliance.id}, :ranking => rank, :updated_at => Time.now, :created_at => Time.now)
            statsd_batch.gauge("general.alliance.#{GraphitePathModule.path_for_stats(alliance.id)}.rank", rank)
            rank += 1
          end
        end

      }
      statsd_batch.flush
    end
  end
end