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

#******* minimise widget on dashboard
init_minimise_button = () ->
  #minimise widgets bassed on stored array
  store_item = JSON.parse(localStorage.getItem('tsn_dashboard_min_array'))
  store_item = [] if store_item == null
  for id in store_item
    $("##{id} .minimisable").hide()
    icon = $("##{id} .min_link i").first()
    icon.toggleClass('icon-resize-small')
    icon.toggleClass('icon-resize-full')
  $('.min_link').click((e) ->
    e.preventDefault()
    min_id = $(this).data('minId')

    $("##{min_id}  .minimisable").slideToggle()
    #then toggle icon class
    icon = $(this).children('i').first()
    icon.toggleClass('icon-resize-small')
    icon.toggleClass('icon-resize-full')

    #store which widgets are minimised
    store_item = JSON.parse(localStorage.getItem('tsn_dashboard_min_array'))
    store_item = [] if store_item == null
    check_index = store_item.indexOf(min_id)
    if check_index == -1
      store_item.push min_id
    else
      store_item.splice(check_index, 1)
    localStorage.setItem('tsn_dashboard_min_array',JSON.stringify(store_item))

  )



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

date_range_picker = ->
  $('.date_range_form').each ->
    main = $(this)
    $(main.data('fromAltId')).datepicker(
      altField: main.data('fromId')
      dateFormat: "DD, d MM, yy"
      altFormat: "yy-mm-d"
      changeMonth: true
      onClose: (selectedDate) ->
        $(main.data('toAltId')).datepicker "option", "minDate", selectedDate
    ).keyup (e) ->
      $.datepicker._clearDate this  if e.keyCode is 8 or e.keyCode is 46
    $(main.data('toAltId')).datepicker(
      altField: main.data('toId')
      dateFormat: "DD, d MM, yy"
      altFormat: "yy-mm-d"
      changeMonth: true
      onClose: (selectedDate) ->
        $(main.data('fromAltId')).datepicker "option", "maxDate", selectedDate
    ).keyup (e) ->
      $.datepicker._clearDate this  if e.keyCode is 8 or e.keyCode is 46

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

report_comment = () ->
  $('.report-btn').click( ->
    comment_id = $(this).data('commentId')
    bootbox.prompt "Please enter a reason for reporting this comment.", (result) ->
      unless result is null
        w = window.location
        new_url = "#{w.protocol}//#{w.hostname}:#{w.port}/comments/#{comment_id}/report?reason=#{encodeURIComponent(result)}"
        window.location.href = new_url

    false
  )

init_countdown_timers = () ->
  #init anycountdown timeers
  $('.countdown_timer').each ->
    div = $(this)
    div.countdown {
      date: div.data('countdownTo')
      render: (data) ->
        el = $(this.el)
        el.empty()
        el.append("<div>" + this.leadingZeros(data.years, 4) + " <span>years</span></div>") if data.years > 0
        el.append("<div>" + this.leadingZeros(data.days, 3) + " <span>days</span></div>") if data.years > 0 || data.days > 0
        el.append("<div>" + this.leadingZeros(data.hours, 2) + " <span>hrs</span></div>")
        el.append("<div>" + this.leadingZeros(data.min, 2) + " <span>min</span></div>")
        el.append("<div>" + this.leadingZeros(data.sec, 2) + " <span>sec</span></div>")
      onEnd: () ->
        if $(this.el).data('refresh') == true
          location.reload(true)
    }
$(document).ready( ->
  setup_announcement()
  custom_alert_box()
  placeholder_check()
  date_range_picker()
  init_minimise_button()
  init_countdown_timers()
  report_comment()

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
    $('#test').text('idle')
    # function you want to fire when the user goes idle
    TSN.notifications_timer.pause() unless !TSN.notifications_timer?
    TSN.bat_timer.pause() if typeof(TSN.bat_timer) == 'object'
    TSN.activity_pause = true

  $(document).on "active.idleTimer", ->
    $('#test').text('active')
    # function you want to fire when the user becomes active again
    TSN.notifications_timer.play()  unless !TSN.notifications_timer?
    TSN.bat_timer.play() if typeof(TSN.bat_timer) == 'object'
    TSN.activity_pause = false

  $("a[data-toggle=popover]").popover().click (e) ->
    e.preventDefault()

  #start the bat timer
  if rails.bat == true && typeof(TSN.bat_timer) != 'object'
    TSN.bat_timer = $.timer(Bats.spawn_bats, 40000, true)
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

