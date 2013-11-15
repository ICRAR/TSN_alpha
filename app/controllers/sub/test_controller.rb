class Sub::TestController < Sub::ApplicationController
  def index
    @profiles = Profile.limit(10)
  end
end
