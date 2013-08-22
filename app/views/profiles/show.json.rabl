object @profile
attributes :id, :name, :country_name
glue :general_stats_item do |g|
  if g.nereus_stats_item != nil
    child :nereus_stats_item => :nereus do |n|
      attributes :nereus_id, :online_now, :mips_now,
                 :online_today, :mips_today
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
child :alliance do
  attributes :id, :name
  node(:url) {|a| alliance_url(a,:format => :json)}
end
child :trophies, :object_root => false do
  attributes :id, :title, :credits
  node(:desc) {|t| t.desc(@trophy_ids)}
  node(:credits) {|t| t.show_credits(@trophy_ids)}
  node(:image_url) {|t| t.image.url}
  node(:url) {|t| trophy_url(t,:format => :json)}
end