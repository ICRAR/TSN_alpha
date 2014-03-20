class TrophiesJob < Delayed::BaseScheduledJob
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

        #update leaderboard based trophies
        leader_board_sets = TrophySet.where{set_type == 'leader_board_position_active'}
        leader_board_sets.each do |set|
          set.trophies.each do |trophy|
            trophy.award_by_leader_board()
          end
        end

        #update galaxy count trophies
        galaxy_count_sets = TrophySet.where{set_type == 'galaxy_count_active'}
        galaxy_user_count_array = GalaxyUser.all_users_count
        galaxy_count_sets.each do |set|
          set.trophies.each do |trophy|
            trophy.award_by_galaxy_count(nil, galaxy_user_count_array)
          end
        end


        #finally aggregate all trophy notifications so users to do get spammed
        Trophy.aggregate_notifications

      }



      @statsd_batch.flush
    end
  end
end