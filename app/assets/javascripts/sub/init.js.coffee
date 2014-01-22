$(document).ready(
  jQuery ->
    faye = new Faye.Client("http://localhost:9292/faye")
    faye.subscribe "/messages/new", (data) ->
      eval data
)