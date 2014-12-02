TheSkyMap.CurrentPlayerController = Ember.ObjectController.extend(TheSkyMap.Countdownable, {
  content: null
  init: ->
    @_super()

    data = $('#data').data('currentPlayer').current_player
    @.get('store').push 'current_player', data
    currentPlayer = @.get('store').getById('current_player', data.id)
    @.set "content", currentPlayer

    rat = @get('next_update_time')
    @countdown_set(rat*1000) unless rat == 0
  countdown_complete: () ->
    @send('update_details')
  actions:
    update_details: () ->
      controller = this
      Ember.$.getJSON "/the_sky_map/map/current_player", (data) ->
        controller.get('store').pushPayload 'currentPlayer', data
        currentProfile =  controller.get('store').getById('currentPlayer',data.current_player.id)
        controller.set "content", currentProfile
        rat = controller.get('next_update_time')
        controller.countdown_set(rat*1000) unless rat == 0
})