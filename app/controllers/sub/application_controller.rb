class Sub::ApplicationController < ApplicationController
  layout "sub"
  Footnotes::Filter.notes = []
end
