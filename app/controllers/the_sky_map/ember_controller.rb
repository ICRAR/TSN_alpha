module TheSkyMap
  class EmberController < TheSkyMap::ApplicationController
    def index
      @current_player = current_player_json
    end

    def current_player
      respond_to do |format|
        format.json { render json: current_player_json }
      end
    end
    skip_before_filter :signed_in, :only => [:trigger_refresh]
    skip_before_filter :check_player, :only => [:trigger_refresh]
    def trigger_refresh
      respond_to do |format|
        format.text {
          if params["secret_token"] == APP_CONFIG['faye_token']
            PostToFaye.request_refresh()
            render :text => "Success"
          else
            render :text => "Failed"
          end
        }
      end
    end
  end
end
