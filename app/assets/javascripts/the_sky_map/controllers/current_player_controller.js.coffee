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
      save_this = this
      Ember.$.getJSON "/the_sky_map/map/current_player", (data) ->
        save_this.send('update_from_data', data)
    update_from_data: (data) ->
      @get('store').pushPayload 'currentPlayer', data
      currentProfile =  @get('store').getById('currentPlayer',data.current_player.id)
      @set "content", currentProfile
      rat = @get('next_update_time')
      @countdown_set(rat*1000) unless rat == 0
})