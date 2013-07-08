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
child :trophies, :object_root => false do
  attributes :id, :title, :credits
  node(:desc) {|t| t.desc(@trophy_ids)}
  node(:credits) {|t| t.show_credits(@trophy_ids)}
  node(:image_url) {|t| t.image.url}
  node(:url) {|t| trophy_url(t,:format => :json)}
end