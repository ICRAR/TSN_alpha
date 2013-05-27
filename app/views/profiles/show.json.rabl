object @profile
attributes :id, :name, :country
glue :general_stats_item do
  glue :nereus_stats_item do
    attribute :nereus_id
  end
  glue :boinc_stats_item do
    attribute :boinc_id
  end
  attributes :rank
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