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
  end
end
