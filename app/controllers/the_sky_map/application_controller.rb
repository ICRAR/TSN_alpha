module TheSkyMap
  class ApplicationController < ApplicationController
    layout "theSkyMap"
    Footnotes::Filter.notes = []
    authorize_resource

  end
end
