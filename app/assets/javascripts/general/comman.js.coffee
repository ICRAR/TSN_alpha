this.TSN = new Object();
#**** share box for trophies
TSN.trophy_share = (obj_id,trophy_name, trophy_url) ->
  tbx = document.getElementById(obj_id)
  $("##{obj_id}").empty()
  svcs = [1..4]

  for s of svcs
    tbx.innerHTML += "<a class=\"addthis_button_preferred_" + s + "\"></a>"
  tbx.innerHTML += "<a class=\"addthis_button_compact\"></a>"
  tbx.innerHTML += "<a class=\"addthis_counter addthis_bubble_style\"></a>"

  addthis.toolbox "##{obj_id}", {ui_cobrand: "theSkyNet"}, {
    url: trophy_url,
    title: "I just earned '#{trophy_name}' from theSkyNet for playing my part in discovering our Universe! ",
    templates:
      twitter: "I just earned '#{trophy_name}' from @_theSkyNet for playing my part in discovering our Universe! {{url}}"
  }
#**************************************


#******* custom alert box using bootbox
custom_alert_box = ->
  $.rails.allowAction = (link) ->
    return true unless link.attr('data-confirm')
    $.rails.showConfirmDialog(link) # look bellow for implementations
    false # always stops the action since code runs asynchronously

  $.rails.handleLink = (link) ->
    if link.data("remote") isnt `undefined`
      $.rails.handleRemote link
    else $.rails.handleMethod link  if link.data("method")
    true

  $.rails.showConfirmDialog = (link) ->
    message = link.data("confirm")
    bootbox.confirm message, "Cancel", "Yes", (confirmed) ->
      if confirmed
        link.removeAttr('data-confirm')
        $.rails.handleLink(link);
#**************************************


setup_announcement = ->
  $(".announcement").each( ->
    block = $(this)
    block.children('.btn-group').children(".announcement-hide").click({parent: this}, (e)->
      $(e.data.parent).alert('close')
    )
    block.children('.btn-group').children(".announcement-view").click({parent: this}, (e)->
      id = $(e.data.parent).data('id')
      $.ajax("/news/#{id}/dismiss.json")
      $(e.data.parent).alert('close')
    )
    block.children('.btn-group').children(".announcement-dismiss").click({parent: this}, (e)->
      id = $(e.data.parent).data('id')
      $.getJSON("/news/#{id}/dismiss.json", (data) ->
        if data.new
          block.replaceWith(data.html)
          setup_announcement()
        else
          block.alert('close')
      )
    )
  )

placeholder_check = () ->
  if jQuery.support.placeholder == false
    $('[placeholder]').each (index, element) =>
      label = $(element).wrap(
        '<label for="' + $(element).attr('id') + '" />'
      ).parent()
      label.html(
        $(element).attr('placeholder') + ': ' + label.html()
      )

$(document).ready( ->
  setup_announcement()
  custom_alert_box()
  placeholder_check()

  #fix for bootstrap modal's getting stuck behind the background
  $('.modal').appendTo("body")

  #using bootstrap-progressbar
  $('.progress .bar').progressbar(
    display_text: 1
  )
  $('a.fancybox').fancybox()
  $('a.fancybox_image').fancybox(
    'type' : 'image'
  )
  $('.js-tooltip').tooltip()
  if rails.user_signed_in
    Notifications.update()
    if (!TSN.notifications_timer?)
      TSN.notifications_timer = $.timer(Notifications.update,60000, true)

  #setup an idle timer stop updating users notifications if they've been idle for 2 mins
  $( document ).idleTimer( 120000 );
  $(document).on "idle.idleTimer", ->
    # function you want to fire when the user goes idle
    TSN.notifications_timer.pause() if typeof(TSN.notifications_timer) == 'object'
    TSN.bat_timer.pause() if typeof(TSN.bat_timer) == 'object'
    TSN.activity_pause = true

  $(document).on "active.idleTimer", ->
    # function you want to fire when the user becomes active again
    TSN.notifications_timer.play()  if typeof(TSN.notifications_timer) == 'object'
    TSN.bat_timer.play() if typeof(TSN.bat_timer) == 'object'
    TSN.activity_pause = false

  $("a[data-toggle=popover]").popover().click (e) ->
    e.preventDefault()

  #start the bat timer
  if rails.bat == true && typeof(TSN.bat_timer) != 'object'
    TSN.bat_timer = $.timer(TSN.spawn_bats, 40000, true)
    TSN.bat_timer.once(2000)
    getMousePosition = (timeoutMilliSeconds) ->
      # "one" attaches the handler to the event and removes it after it has executed once
      $(document).one "mousemove", (event) ->
        window.mousePos = [event.pageX ,event.pageY]
        # set a timeout so the handler will be attached again after a little while
        setTimeout (->
          getMousePosition timeoutMilliSeconds
        ), timeoutMilliSeconds

    # start storing the mouse position every 100 milliseconds
    getMousePosition 100
    window.mousePos = [0,0]

  #snow at christmas
  if rails.snow == true
    $(document).snowfall({round: true, minSize: 1, maxSize:5, flakeCount : 250});

  #start fireworks
  if rails.fireworks == true
    Fireworks.run()
  true
)
TSN.spawn_bats = () ->
  for i in [0..20]
    o = $("h1").offset()
    TSN.spawn_bat(o.left+110,o.top+75)
TSN.spawn_bat = (x,y) ->
  b = new TSN.Bat(x,y)
  b.home = [Math.random()*200+200,Math.random()*500+200]
  b.fly()
  b.live(Math.random()*10+10)
  b

TSN.bat_id = 0
class TSN.Bat
  constructor: (x,y) ->
    @home = [200,200]
    TSN.bat_id += 1
    @name = "bat#{TSN.bat_id}"
    @pos = [x,y]
    @alive = true
    @vel = [10,10]
    $('body').append("<div id=\"#{@name}\" class=\"bat\" style='left:#{x}px; top:#{y}px;'>/^v^\\</div>")
    @move
  move: () ->
    @update('x')
    @update('y')
    $("\##{@name}").animate({
      left:@pos[0],
      top: @pos[1]
    }, 100)
  fly: () ->
    @fly_timer = $.timer =>
      @move()
    , 100
    , true
  die: () ->
    $("\##{@name}").remove()
  live: (t) ->
    #the bat will live for between t seconds before flying away and dieing
    @life_timer = $.timer =>
      @fly_away()
    , 3000
    , false
    @life_timer.once(t*1000)
  fly_away: () ->
    @alive = false
    dir = Math.random()*2*Math.PI
    @home[0] = $(window).width()*(0.5 + 4*Math.cos(dir))
    @home[1] = $(window).height()*(0.5 + 4*Math.sin(dir))
    @die_timer = $.timer =>
      @die()
    , 3000
    , false
    @die_timer.once(3000)
  stop: () ->
    @fly_timer.pause()
  update: (c) ->
    i = if (c == 'x') then 0 else 1
    v = @vel[i]  #start at current speed
    v += (Math.random()-.5)*10 #add a random amount

    #calculates the distance to home + a random number (maxed and mined)
    edge = if (c == 'x') then ($(window).width()- 100) else ($(window).height() - 300)
    if @alive & window.mousePos[i] > 100 &  window.mousePos[i] < edge
      h = window.mousePos[i]
      home_trend = 0.02
    else
      h = @home[i]
      home_trend = 0.007
    dis = h-@pos[i]
    dis = if (dis > 400) then 300 else dis
    dis = if (dis < -400) then -300 else dis
    dis += (Math.random()-.5)*30

    v += dis* home_trend #trend towards home
    v -= v*.03 #remove a damping factor

    @vel[i] = v
    @pos[i] += @vel[i]
  test: () ->
    t = 0
    for x in [1..100000]
      t += (Math.random()-.50000000001)
    t



TSN.GRAPHITE =  {
  stats_path: (id) ->
    pad = new Array(1+9).join('0')
    padded = (pad+id).slice(-9)
    padded.match(/.{3}/g).join('.')
}

TSN.monthDiff = (d1, d2) ->
  months = undefined
  months = (d2.getFullYear() - d1.getFullYear()) * 12
  months -= d1.getMonth()
  months += d2.getMonth()
  months += (if (d2.getDate() > d1.getDate()) then 1 else 0)
  (if months <= 0 then 0 else months)
TSN.months_from_launch = ->
  d1 = new Date(2011, 8, 13)
  d2 = new Date()
  TSN.monthDiff(d1, d2) + 1
