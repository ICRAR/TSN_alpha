TheSkyMap.ActionController = Ember.ObjectController.extend(TheSkyMap.Countdownable, {
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
})
