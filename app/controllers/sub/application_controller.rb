module Sub
  class ApplicationController < ApplicationController
    layout "sub"
    Footnotes::Filter.notes = []
    authorize_resource

  end
end
