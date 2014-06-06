module TheSkyMap
  class ApplicationController < ApplicationController
    before_filter :signed_in
    layout "theSkyMap"
    Footnotes::Filter.notes = []
    #authorize_resource
    private
    def current_player_json
      if user_signed_in?
        player = current_user.profile.the_sky_map_player
        TheSkyMap::CurrentPlayerSerializer.new(player).to_json
      else
        {current_player: {id: 0, user_signed_in: false, name: 'Guest'}}.to_json
      end
    end
    def current_player_hash
      ActiveSupport::JSON.decode(current_player_json)
    end
  end
end
