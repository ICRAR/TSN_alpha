this.Bats = new Object();
Bats.spawn_bats = () ->
  for i in [0..20]
    o = $("h1").offset()
    Bats.spawn_bat(o.left+110,o.top+75)
Bats.spawn_bat = (x,y) ->
  b = new Bats.Bat(x,y)
  b.home = [Math.random()*200+200,Math.random()*500+200]
  b.fly()
  b.live(Math.random()*10+10)
  b

Bats.bat_id = 0
class Bats.Bat
  constructor: (x,y) ->
    @home = [200,200]
    Bats.bat_id += 1
    @name = "bat#{Bats.bat_id}"
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
