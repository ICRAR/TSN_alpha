object @trophy
attributes :id, :title, :desc, :image_url, :credits
node(:image_url) {|t| t.image.url}
node(:url) {|t| trophy_url(t,:format => :json)}