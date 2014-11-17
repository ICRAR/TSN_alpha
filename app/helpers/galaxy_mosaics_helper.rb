module GalaxyMosaicsHelper
  def profile_list(profiles)
    list = []
    profiles.each do |profile|
      link = "<a href=\"/profiles/#{ERB::Util.html_escape(profile.id)}\">#{profile.name}</a>"
      list << link
    end
    (list.to_sentence + '.').html_safe
  end
end