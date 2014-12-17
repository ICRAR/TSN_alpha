TheSkyMap.ActionController = Ember.ObjectController.extend(TheSkyMap.Countdownable, {
  needs: ['currentPlayer']
  options_string: (() ->
    out_array = []
    for key, value of @get('options')
      out_array.push "#{key}: #{value}"
    "(#{out_array.join(', ')})"
  ).property('options')
  init: () ->
    @_super()
    rat = @get('run_at_time')
    @countdown_set(rat*1000) unless rat == 0
  countdown_complete: () ->
    @.get('content').reload()
  special_cost: (() ->
    Math.ceil(@get('countdown_seconds_total')/60)
  ).property('countdown_seconds_total')
  special_button_enable: (() ->
    (@get('special_cost') <= @get('controllers.currentPlayer.content.currency_available_special'))
  ).property('special_cost','controllers.currentPlayer.content.currency_available_special')
  show_special_button: (() ->
    (@get('current_state') == 'queued_next') && !@get('run_special_clicked') && @get('skippable') == true
  ).property('current_state','run_special_clicked','skippable')
  actionable_link: (() ->
    model = @get('actionable')
    if model
      "#{model.constructor.toString().split('.').pop().toLowerCase()}.show"
    else
      ""
  ).property('actionable')
  run_special_clicked: false
  actions:
    run_special: () ->
      @set('run_special_clicked',true)
      save_this = @
      @stop_countdown()
      store = @store
      action_path = store.adapterFor(this).buildURL('action',@.get('id'))
      run_special_path = "#{action_path}/run_special"
      actionable_controller = @get('target')
      $.get(run_special_path,
        {},
      ).done((data) ->
        store.pushPayload('action', data)
        actionable_controller.send('update_actions')if $.isFunction(actionable_controller._actions['update_actions'])
      ).fail((error) ->
        if error.status == 404
          save_this.transitionToRoute('home')
      )
})
