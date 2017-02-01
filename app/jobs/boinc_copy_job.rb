class BoincCopyJob < Delayed::BaseScheduledJob
  run_every 1.hour

  def perform
    #start statsd batch
    statsd_batch = Statsd::Batch.new($statsd)
    begin
      bench_time = Benchmark.bm do |bench|
        bench.report('users1') {
          next_id = SiteStat.try_get("boinc_copy_job_last_userid", 0).value
          boinc_local_items = BoincStatsItem.where{boinc_id >= next_id}.all
          boinc_hash = Hash[*boinc_local_items.map{|b| [b.boinc_id, b]}.flatten]
          # Only copy users who have credit, the others really don't matter.
          BoincRemoteUser.where{id >= my{next_id} & total_credit > 0}.find_in_batches do |b|
            b.check_local boinc_hash[b.id]
          end
          SiteStat.set("boinc_copy_job_last_userid", BoincRemoteUser.maximum(:id))
        }
        bench.report('alliances') {
          begin
            alliance_local_items = Alliance.where{pogs_team_id > 0} ;
            alliance_hash = Hash[*alliance_local_items.map{|a| [a.pogs_team_id, a]}.flatten];
            PogsTeam.where{total_credit > 0}.each {|t| puts "next id: #{t.id}"; t.copy_to_local(alliance_hash[t.id])}
          rescue ArgumentError  => e
            msg =  "Error in BOINC Job whilst updating teams\n\n"
            msg +=  e.to_s
            msg += "\n\n"
            msg += e.backtrace.join("\n")
            AdminMailer.debug(msg, "Error in BOINC Job").deliver
          end
        }
        bench.report('users2') {
          #update team members not in team_delta
          ids = BoincRemoteUser.where{(total_credit > 0) & (teamid > 0)}.select([:id, :teamid])
          ids_array = ids.map {|i| i.id}
          team_hash = ids.map {|i| i.teamid}.uniq
          ids_team_hash = Hash[*ids.map{|i| [i.id, i.teamid]}.flatten]
          alliances = Alliance.where{pogs_team_id.in team_hash}
          alliance_ids = alliances.map {|i| i.id}
          alliances_by_teamid = Hash[*alliances.map{|i| [i.pogs_team_id, i]}.flatten]

          profiles = Profile.joins{general_stats_item.boinc_stats_item}.
              where{((alliance_id == nil) | (alliance_id.not_in alliance_ids)) & (boinc_stats_items.boinc_id.in ids_array)}.
              select('profiles.*').
              select{boinc_stats_items.boinc_id.as boinc_id}.
              select{general_stats_items.total_credit.as total_credit}
          Profile.transaction do
            profiles.each do |profile|
              team_id = ids_team_hash[profile.boinc_id]
              alliance = alliances_by_teamid[team_id]
              unless alliance.nil?
                AllianceMembers.join_alliance_from_boinc_from_start(profile,alliance)
                if profile.alliance.nil?
                  profile.alliance = alliance
                  profile.save
                else
                  UserMailer.alliance_sync_removal(profile, profile.alliance, alliance).deliver
                  profile.leave_alliance(false, 'User was in the wrong alliance according to the BOINC users table')
                  profile.alliance = alliance
                  profile.save
                end
                AllianceMembers.create_notification_join(profile.alliance_items.last.id)
              end
            end
          end
        }
      end
      puts bench_time.to_yaml
      statsd_batch.gauge("boinc.stat.copy_update_time",bench_time[0].total)
      statsd_batch.flush
    end
  end
end