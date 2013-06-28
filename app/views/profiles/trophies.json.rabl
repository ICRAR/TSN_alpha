object @profile
attributes :id
child :trophies do
  attributes :id, :title, :credits
  node(:desc) {|t| t.desc(@trophy_ids)}
  node(:credits) {|t| t.show_credits(@trophy_ids)}
  node(:image_url) {|t| t.image.url}
  node(:url) {|t| trophy_url(t,:format => :json)}
end