TheSkyMap.CurrentPlayerController = Ember.ObjectController.extend
  content: null
  mini_map_x_min: (() ->
    @.get('player_options').mini_map_x_min
  ).property('player_options')
  mini_map_x_max: (() ->
    @.get('player_options').mini_map_x_max
  ).property('player_options')
  mini_map_y_min: (() ->
    @.get('player_options').mini_map_y_min
  ).property('player_options')
  mini_map_y_max: (() ->
    @.get('player_options').mini_map_y_max
  ).property('player_options')
  retrieveCurrentUser: ->
    controller = this
    Ember.$.getJSON "/sub/ember/current_player", (data) ->
      controller.get('store').pushPayload 'currentPlayer', data
      currentProfile =  controller.get('store').find(data.current_player.id)
      controller.set "content", currentProfile
  init: ->
    data = $('#data').data('currentPlayer').current_player
    @.get('store').push 'current_player', data
    currentPlayer = @.get('store').getById('current_player', data.id)
    @.set "content", currentPlayer
