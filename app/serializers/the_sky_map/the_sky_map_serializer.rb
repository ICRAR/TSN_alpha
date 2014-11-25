class TheSkyMap::TheSkyMapSerializer < ActiveModel::Serializer
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper
  include ActionView::Helpers::AssetTagHelper
  def current_player
    current_user.profile.the_sky_map_current_player
  end
end