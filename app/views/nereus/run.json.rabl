object false
node(:run_link_no_json) {url_for(run_nereus_url)}
node(:current_user_id) {current_user.profile.id}
node(:current_user_neresu_id) {@nereus_id}
node(:applet_url) {"http://#{@server}/nereus/NereusApplet.html?userID=#{@nereus_id}"}