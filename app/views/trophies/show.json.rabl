object @trophy
attributes :id
node(:credits) {|t| t.show_credits(@trophy_ids)}
node(:title) {|t| t.title}
node(:description) {|t| t.desc(@trophy_ids).html_safe}
node(:image_url) {|t| t.image.url}
node(:num_winners) {|t| t.profiles_trophies.size}