TheSkyMap.Countdownable = Ember.Mixin.create({
  countdown_date: new Date()
  countdown_seconds_total: 0
  countdown_seconds: (() ->
    @get('countdown_seconds_total') % 60
  ).property('countdown_seconds_total')
  countdown_minutes: (() ->
    Math.floor((@get('countdown_seconds_total') / 60)) % 60
  ).property('countdown_seconds_total')
  countdown_hours:(() ->
    Math.floor((@get('countdown_seconds_total') / 3600)) % 24
  ).property('countdown_seconds_total')
  countdown_days: (() ->
    Math.floor(@get('countdown_seconds_total') / 86400)
  ).property('countdown_seconds_total')
  countdown_running: false
  countdown_object: null
  init_timer: () ->
    obj = this
    timer = $.timer(
      () ->
        obj.update_countdown()
      1000
      false
    )
    timer
  init: () ->
    @_super()
    @set('countdown_object', @init_timer())
  countdown_set: (ms_time) ->
    current_time = $.now()
    new_date  = new Date(ms_time)
    if ms_time > current_time
      @set('countdown_date', new_date)
      @update_countdown()
      @start_countdown()
  update_countdown: () ->
    if @isDestroyed
      @stop_countdown()
    else
      current_date = new Date()
      seconds_remaining = Math.floor((@get('countdown_date')-current_date)/1000)
      @set('countdown_seconds_total',seconds_remaining)
      if seconds_remaining < 1
        @stop_countdown()
        @countdown_complete()
  start_countdown: () ->
    @get('countdown_object').play(false)
  stop_countdown: () ->
    @get('countdown_object').stop()
})