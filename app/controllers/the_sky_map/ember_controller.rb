module TheSkyMap
  class EmberController < TheSkyMap::ApplicationController
    def index
      @profiles = Profile.limit(10)
      @current_player = current_player_json
    end

    def current_player
      respond_to do |format|
        format.json { render json: current_player_json }
      end
    end

    private
    def current_player_json
      if user_signed_in?
        player = current_user.profile.the_sky_map_player
        TheSkyMap::CurrentPlayerSerializer.new(player).to_json
      else
        {current_player: {id: 0, user_signed_in: false, name: 'Guest'}}.to_json
      end
    end
  end
end
