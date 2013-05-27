object @trophy
attributes :id, :credits
node(:title) {|t| t.title.titlecase}
node(:description) {|t| t.desc.html_safe}
node(:image_url) {|t| t.image.url}
node(:num_winners) {|t| t.profiles_trophies.size}