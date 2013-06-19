object @galaxy
attributes :id, :name, :ra_cent, :dec_cent, :redshift, :type, :dimension_x, :dimension_y
node (:percentage_complete) {|g| (g.pixel_count == 0 || g.pixels_processed == 0) ? '0.00%' : (g.pixel_count*100.0/g.pixels_processed)}
node (:more_info_url) {|g| g.more_info_url}
child @galaxy => :filter_images do
  node('1') { @galaxy.image_url(1,@boinc_id)}
  node('2') { @galaxy.image_url(2,@boinc_id)}
  node('3') { @galaxy.image_url(3,@boinc_id)}
  node('4') { @galaxy.image_url(4,@boinc_id)}
end
child @galaxy => :calculated_images do
  node('mu') { @galaxy.parameter_image_url('mu')}
  node('m') { @galaxy.parameter_image_url('m')}
  node('ldust') { @galaxy.parameter_image_url('ldust')}
  node('sfr') { @galaxy.parameter_image_url('sfr')}
end