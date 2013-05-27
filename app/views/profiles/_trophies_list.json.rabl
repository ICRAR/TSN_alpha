object @trophy
attributes :id, :name, :image_url
node(:image_url) {|t| t.image.url}
node(:url) {|t| trophy_url(t,:format => :json)}