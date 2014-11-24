TheSkyMap.CurrentPlayerController = Ember.ObjectController.extend
  content: null
  retrieveCurrentUser: ->
    controller = this
    Ember.$.getJSON "/the_sky_map/map/current_player", (data) ->
      controller.get('store').pushPayload 'currentPlayer', data
      currentProfile =  controller.get('store').find(data.current_player.id)
      controller.set "content", currentProfile
  init: ->
    data = $('#data').data('currentPlayer').current_player
    @.get('store').push 'current_player', data
    currentPlayer = @.get('store').getById('current_player', data.id)
    @.set "content", currentPlayer
