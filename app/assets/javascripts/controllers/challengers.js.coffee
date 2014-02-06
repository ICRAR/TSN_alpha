# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
TSN = this.TSN
TSN.challengers = new Object;


TSN.challengers.show = () ->
  TSN.rickshaw_graph_challenge($("#graph"),false)

TSN.challengers.compare = () ->
  TSN.rickshaw_graph_challenge($("#graph_score"),true)
  TSN.rickshaw_graph_challenge($("#graph_rank"),true)



