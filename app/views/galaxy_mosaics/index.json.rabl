collection @mosaics
attribute :id, :image_updated_at, :options, :galaxy_ids
node(:image_url) {|n| n.image.url}
node(:image_thumbnail_url) {|n| n.image.url(:thumb)}