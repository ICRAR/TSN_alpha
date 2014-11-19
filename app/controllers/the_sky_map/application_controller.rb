module TheSkyMap
  class ApplicationController < ApplicationController
    before_filter :signed_in
    before_filter :check_player
    def check_player
      if user_signed_in?
        player = current_user.profile.the_sky_map_player
        if player.nil?
          #redirect to theSkyMap Sign Up page
          redirect_to the_sky_map_reg_path
        end
      end
    end
    layout "theSkyMap"
    #remove footnotes from dev
    begin
      Footnotes::Filter.notes = []
    rescue NameError
    end
    #authorize_resource
    private
    def current_player_object
      current_user.profile.the_sky_map_player
    end
    def current_map_id
      current_player_object.game_map_id
    end
    def current_player_json
      if user_signed_in?
        TheSkyMap::CurrentPlayerSerializer.new(current_player_object).to_json
      else
        {current_player: {id: 0, user_signed_in: false, name: 'Guest'}}.to_json
      end
    end
    def current_player_hash
      ActiveSupport::JSON.decode(current_player_json)
    end

    #adds kaminari pagination data if they exist to the meta tag.
    def pagination_meta(relation, meta = {})
      if relation.respond_to?(:total_pages) && relation.respond_to?(:current_page)
        meta.merge({pagination:{
            total_pages: relation.total_pages,
            current_page: relation.current_page,
            count: relation.count,
            total_count: relation.total_count,
        }})
      else
        meta
      end
    end
  end
end
