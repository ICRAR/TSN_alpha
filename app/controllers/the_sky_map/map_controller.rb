module TheSkyMap
  class MapController < TheSkyMap::ApplicationController
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
            TheSkyMap::GameMap.each do |map|
              PostToFaye.request_refresh(map.id)
            end
            render :text => "Success"
          else
            render :text => "Failed"
          end
        }
      end
    end
    ### static page for theSkyMap signup
    def manage
      page = params[:page].to_i || 1
      per_page = params[:per_page].to_i || 10
      @players = current_user.profile.the_sky_map_players.page(page).per(per_page).for_show()
      render layout: 'application'
    end
    def select
      current_user.profile.the_sky_map_select_game(params[:id])

      page = params[:page].to_i || 1
      per_page = params[:per_page].to_i || 10
      @players = current_user.profile.the_sky_map_players.page(page).per(per_page).for_show()
      render action: "manage", layout: 'application'
    end
    ### static page for theSkyMap signup
    skip_before_filter :check_player, only: :tsm_reg
    def tsm_reg
      render layout: 'application'
    end
  end
end
