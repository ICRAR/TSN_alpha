object @profile
attributes :id, :name, :country
glue :general_stats_item do |g|
  if g.nereus_stats_item != nil
    child :nereus_stats_item => :nereus do |n|
      attributes :nereus_id, :active, :paused, :online_now, :mips_now,
                 :online_today, :mips_today, :monthly_network_usage_mb,
                 :network_limit_mb, :limited => :network_limited
      node(:pause_url) {url_for(pause_nereus_url :format => :json)}
      node(:resume_url) {url_for(resume_nereus_url :format => :json)}
      node(:run_url) {url_for(run_nereus_url :format => :json)}

    end
  end
  glue :boinc_stats_item do
    attributes :boinc_id
  end
  attributes :credits_to_next_trophy, :rank
  node(:postition_in_ladder_url) {profiles_url({:rank => @profile.general_stats_item.rank, :format => :json}) }

end
node(:total_credit) {|p| p.general_stats_item.total_credit }
node(:gravtar_url) { |p| p.avatar_url(128) }
child :alliance do
  attributes :id, :name
  node(:url) {|a| alliance_url(a,:format => :json)}
end
child :trophies do
  extends "profiles/trophies_list"
end