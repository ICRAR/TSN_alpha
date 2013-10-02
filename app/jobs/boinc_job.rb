class BoincJob
  include Delayed::ScheduledJob
  run_every 1.hour

  def perform
    #start statsd batch
    statsd_batch = Statsd::Batch.new($statsd)
    bench_time = Benchmark.bm do |bench|
      bench.report('stats') {
        total_credit = 0
        total_RAC = 0
        users_with_RAC = 0
        total_users = 0
        boinc_local_items = BoincStatsItem.all
        boinc_hash = Hash[*boinc_local_items.map{|b| [b.boinc_id, b]}.flatten]

        boinc_remote = BoincRemoteUser.all

        BoincStatsItem.transaction do
          boinc_remote.each do |remote|
            local = boinc_hash[remote.id]
            if local.nil?
              local = BoincStatsItem.new
              local.boinc_id = remote.id
              local.report_count = 0
            end
            local.credit = remote.total_credit
            local.RAC = remote.expavg_credit

            total_credit += remote.total_credit
            total_RAC += remote.expavg_credit
            users_with_RAC += (remote.expavg_credit > 10) ? 1 : 0
            total_users += 1
            id = remote.id
            statsd_batch.gauge("boinc.users.#{GraphitePathModule.path_for_stats(id)}.credit",remote.total_credit)
            statsd_batch.gauge("boinc.users.#{GraphitePathModule.path_for_stats(id)}.rac",remote.expavg_credit)

            local.save
          end
        end

        statsd_batch.gauge("boinc.stat.total_credit",total_credit)
        statsd_batch.gauge("boinc.stat.total_rac",total_RAC)
        SiteStat.set("boinc_TFLOPS",(total_RAC*0.000005).round(2))
        statsd_batch.gauge("boinc.stat.total_users",total_users)
        statsd_batch.gauge("boinc.stat.active_users",users_with_RAC)
        statsd_batch.flush

      }
      bench.report('users and alliances') {
        BoincRemoteUser.where{id >= my{BoincStatsItem.next_id}}.each do |b|
            b.check_local
        end

        PogsTeam.where{nusers > 0}.each {|a| a.copy_to_local}


        #update team members not in team_delta
        ids = BoincRemoteUser.teamid_no_team_delta.where{total_credit > 0}.select([:id, :teamid])
        ids_array = ids.map {|i| i.id}
        team_hash = ids.map {|i| i.teamid}
        ids_team_hash = Hash[*ids.map{|i| [i.id, i.teamid]}.flatten]
        alliances = Alliance.where{pogs_team_id.in team_hash}
        alliance_ids = alliances.map {|i| i.id}
        alliances_by_teamid = Hash[*alliances.map{|i| [i.pogs_team_id, i]}.flatten]

        profiles = Profile.joins{general_stats_item.boinc_stats_item}.
            where{(alliance_id.not_in alliance_ids) & (boinc_stats_items.boinc_id.in ids_array)}.
            select('profiles.*').
            select{boinc_stats_items.boinc_id.as boinc_id}.
            select{general_stats_items.total_credit.as total_credit}
        Profile.transaction do
          profiles.each do |profile|
            team_id = ids_team_hash[profile.boinc_id]
            alliance = alliances_by_teamid[team_id]
            unless alliance.nil?
              member = AllianceMembers.new
              member.alliance_id = alliance.id
              member.profile_id = profile.id
              member.join_date = alliance.created_at
              member.start_credit = 0
              member.leave_credit = profile.total_credit
              member.leave_credit ||= 0
              member.leave_date = nil
              member.save

              if profile.alliance.nil?
                profile.alliance = alliance
                profile.save
              else
                profile.leave_alliance
                profile.alliance = alliance
                profile.save
              end
            end
          end
        end
      }
    end
    statsd_batch.gauge("boinc.stat.update_time",bench_time[0].total)
    statsd_batch.flush
  end
end