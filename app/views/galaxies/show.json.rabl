object @galaxy
attributes :id, :name, :ra_cent, :dec_cent, :redshift, :type, :dimension_x, :dimension_y
node (:percentage_complete) {|g| (g.pixel_count == 0 || g.pixels_processed == 0) ? '0.00%' : (g.pixel_count*100.0/g.pixels_processed)}
node (:more_info_url) {|g| g.more_info_url}
if @boinc_id
  child @galaxy => :filter_images do
    node(@galaxy.label(1).html_safe) { image_boinc_galaxy_url(:id => @galaxy.id, :boinc_id => @boinc_id, :colour =>1)}
    node(@galaxy.label(2).html_safe) { image_boinc_galaxy_url(:id => @galaxy.id, :boinc_id => @boinc_id, :colour =>2)}
    node(@galaxy.label(3).html_safe) { image_boinc_galaxy_url(:id => @galaxy.id, :boinc_id => @boinc_id, :colour =>3)}
    node(@galaxy.label(4).html_safe) { image_boinc_galaxy_url(:id => @galaxy.id, :boinc_id => @boinc_id, :colour =>4)}
    end
else
  child @galaxy => :filter_images do
    node('1') { @galaxy.image_url(1)}
    node('2') { @galaxy.image_url(2)}
    node('3') { @galaxy.image_url(3)}
    node('4') { @galaxy.image_url(4)}
  end
end
child @galaxy => :calculated_images do
  node('mu') { @galaxy.parameter_image_url('mu')}
  node('m') { @galaxy.parameter_image_url('m')}
  node('ldust') { @galaxy.parameter_image_url('ldust')}
  node('sfr') { @galaxy.parameter_image_url('sfr')}
end