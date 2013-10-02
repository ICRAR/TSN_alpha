object @profile
attributes :id, :name, :country_name
glue :general_stats_item do |g|
  if g.nereus_stats_item != nil
    child :nereus_stats_item => :SourceFinder do |n|
      attributes :nereus_id, :credit, :daily_credit
    end
  end
  if g.boinc_stats_item != nil
    child :boinc_stats_item do
      attributes :boinc_id, :credit, :RAC
    end
  end
  attributes :credits_to_next_trophy, :rank
  node(:postition_in_ladder_url) {profiles_url({:rank => @profile.general_stats_item.rank, :format => :json, :page=>'me'}) }

end
node(:total_credit) {|p| p.general_stats_item.total_credit }
node(:gravtar_url) { |p| p.avatar_url(128) }
child(:alliance, :if => lambda { |p| !p.alliance.nil? }) do
  attributes :id, :name
  node(:url) {|a| alliance_url(a,:format => :json)}
  end
node(:alliance, :if => lambda { |p| p.alliance.nil? }) {nil}
child @profile.trophies.order("profiles_trophies.created_at DESC, trophies.credits DESC").limit(1).first => :most_recent_trophy do
  attributes :id, :title, :credits
  node(:desc) {|t| t.desc(@trophy_ids)}
  node(:credits) {|t| t.show_credits(@trophy_ids)}
  node(:image_url) {|t| t.image.url}
  node(:url) {|t| trophy_url(t,:format => :json)}
end
node(:trophies_url) {|p| trophies_profile_url(p)}