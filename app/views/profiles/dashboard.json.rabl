object @profile
attributes :id, :name, :country
glue :general_stats_item do |g|
  if g.nereus_stats_item != nil
    child :nereus_stats_item => :SourceFinder do |n|
      attributes :nereus_id, :active, :paused, :online_now, :mips_now,
                 :online_today, :mips_today, :monthly_network_usage_mb,
                 :network_limit_mb, :limited => :network_limited
      node(:pause_url) {url_for(pause_nereus_url)}
      node(:resume_url) {url_for(resume_nereus_url :format => :json)}
      node(:run_url) {url_for(run_nereus_url :format => :json)}
    end
  end
  if g.boinc_stats_item != nil
    child :boinc_stats_item => :POGS do
      attributes :boinc_id, :credit, :RAC
    end
  end
  attributes :credits_to_next_trophy, :rank
  node(:postition_in_ladder_url) {profiles_url({:rank => @profile.general_stats_item.rank, :format => :json, :page=>'me'}) }

end
node(:total_credit) {|p| p.general_stats_item.total_credit }
node(:gravtar_url) { |p| p.avatar_url(128) }
child :alliance do
  attributes :id, :name
  node(:url) {|a| alliance_url(a,:format => :json)}
end
child @profile.trophies.order("profiles_trophies.created_at DESC, trophies.credits DESC").limit(1).first => :most_recent_trophy do
  attributes :id, :title, :credits
  node(:desc) {|t| t.desc[t.id]}
  node(:credits) {|t| t.credits}
  node(:image_url) {|t| t.image.url}
  node(:url) {|t| trophy_url(t,:format => :json)}
end
node(:trophies_url) {|p| trophies_profile_url(p)}