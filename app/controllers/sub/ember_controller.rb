module Sub
  class EmberController < Sub::ApplicationController
    def index
      @profiles = Profile.limit(10)
      @current_profile = current_profile_json
    end

    def current_profile
      respond_to do |format|
        format.json { render json: current_profile_json }
      end
    end

    private
    def current_profile_json
      if user_signed_in?
        profile = current_user.profile
        Sub::CurrentProfileSerializer .new(profile).to_json
      else
        {current_profile: {id: 0, user_signed_in: false, name: 'Guest'}}.to_json
      end
    end
  end
end
