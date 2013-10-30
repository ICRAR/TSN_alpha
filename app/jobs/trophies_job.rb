class TrophiesJob
  include Delayed::ScheduledJob
  run_every 1.hour
  def perform
    @statsd_batch = Statsd::Batch.new($statsd)
    bench_time = Benchmark.bm do |bench|
      bench.report('update trophies') {
        #update classic credit trophies
        classic_sets = TrophySet.where{set_type == 'credit_classic'}
        classic_sets.each do |set|
          set.trophies.each do |trophy|
            trophy.award_by_credit(Profile.where{old_site_user  == true})
          end
        end

        #update modern credit trophies
        modern_sets = TrophySet.where{set_type == 'credit_active'}
        modern_sets.each do |set|
          set.trophies.each do |trophy|
            trophy.award_by_credit()
          end
        end

        #update modern rac trophies
        modern_sets = TrophySet.where{set_type == 'rac_active'}
        modern_sets.each do |set|
          set.trophies.each do |trophy|
            trophy.award_by_rac()
          end
        end

        #update Time based trophies
        time_sets = TrophySet.where{set_type == 'time_active'}
        time_sets.each do |set|
          set.trophies.each do |trophy|
            trophy.award_by_time()
          end
        end
      }



      @statsd_batch.flush
    end
  end
end