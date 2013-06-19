object false
child(@galaxies) do
  attributes :id, :name, :rank, :credits, :rac
  attributes :id, :name, :ra_cent, :dec_cent, :redshift, :type, :dimension_x, :dimension_y
  node (:percentage_complete) {|g| (g.pixel_count == 0 || g.pixels_processed == 0) ? '0.00%' : (g.pixel_count*100.0/g.pixels_processed)}
  node (:more_info_url) {|g| g.more_info_url}
  node (:url) {|g| @boinc_id == nil ? galaxy_url(g,:format => :json) : boinc_galaxy_url(g,g.id,:format => :json)}

end
node(:paginate) do
  paginate_json @galaxies
end