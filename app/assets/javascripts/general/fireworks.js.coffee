this.Fireworks = new Object();
Fireworks.run = () ->
  Fireworks.canvas = document.getElementById("canvasBG_fireworks")
  Fireworks.context = Fireworks.canvas.getContext("2d")

  Fireworks.canvas.width = Fireworks.SCREEN_WIDTH = window.innerWidth  unless Fireworks.SCREEN_WIDTH is window.innerWidth
  Fireworks.canvas.height = Fireworks.SCREEN_HEIGHT = window.innerHeight  unless Fireworks.SCREEN_HEIGHT is window.innerHeight

  Fireworks.mousePos =
    x: 400
    y: 300
  

  Fireworks.particles = []
  Fireworks.rockets = []
  Fireworks.MAX_PARTICLES = 400
  Fireworks.colorCode = 0





  # launch more rockets!!!
  Fireworks.launch = ->
    Fireworks.launchFrom Fireworks.mousePos.x
  Fireworks.launchFrom = (x) ->
    if Fireworks.rockets.length < 10
      rocket = new Fireworks.Rocket(x)
      rocket.explosionColor = Math.floor(Math.random() * 360 / 10) * 10
      rocket.vel.y = Math.random() * -3 - 4
      rocket.vel.x = Math.random() * 6 - 3
      rocket.size = 8
      rocket.shrink = 0.999
      rocket.gravity = 0.01
      Fireworks.rockets.push rocket
  Fireworks.loop = ->

    # update screen size
    Fireworks.canvas.width = Fireworks.SCREEN_WIDTH = window.innerWidth  unless Fireworks.SCREEN_WIDTH is window.innerWidth
    Fireworks.canvas.height = Fireworks.SCREEN_HEIGHT = window.innerHeight  unless Fireworks.SCREEN_HEIGHT is window.innerHeight

    # clear Fireworks.canvas
    Fireworks.context.fillStyle = "rgba(0, 0, 0, 0.05)"
    Fireworks.context.fillRect 0, 0, Fireworks.SCREEN_WIDTH, Fireworks.SCREEN_HEIGHT
    existingRockets = []
    i = 0

    while i < Fireworks.rockets.length

      # update and render
      Fireworks.rockets[i].update()
      Fireworks.rockets[i].render Fireworks.context

      # calculate distance with Pythagoras
      distance = Math.sqrt(Math.pow(Fireworks.mousePos.x - Fireworks.rockets[i].pos.x, 2) + Math.pow(Fireworks.mousePos.y - Fireworks.rockets[i].pos.y, 2))

      # random chance of 1% if Fireworks.rockets is above the middle
      randomChance = (if Fireworks.rockets[i].pos.y < (Fireworks.SCREEN_HEIGHT * 2 / 3) then (Math.random() * 100 <= 1) else false)

      # Explosion rules
      #             - 80% of screen
      #            - going down
      #            - close to the mouse
      #            - 1% chance of random explosion
      #
      if Fireworks.rockets[i].pos.y < Fireworks.SCREEN_HEIGHT / 5 or Fireworks.rockets[i].vel.y >= 0 or distance < 50 or randomChance
        Fireworks.rockets[i].explode()
      else
        existingRockets.push Fireworks.rockets[i]
      i++
    Fireworks.rockets = existingRockets
    existingParticles = []
    i = 0

    while i < Fireworks.particles.length
      Fireworks.particles[i].update()

      # render and save Fireworks.particles that can be rendered
      if Fireworks.particles[i].exists()
        Fireworks.particles[i].render Fireworks.context
        existingParticles.push Fireworks.particles[i]
      i++

    # update array with existing Fireworks.particles - old Fireworks.particles should be garbage collected
    Fireworks.particles = existingParticles
    Fireworks.particles.shift()  while Fireworks.particles.length > Fireworks.MAX_PARTICLES
  Fireworks.Particle = (pos) ->
    @pos =
      x: (if pos then pos.x else 0)
      y: (if pos then pos.y else 0)

    @vel =
      x: 0
      y: 0

    @shrink = .97
    @size = 2
    @resistance = 1
    @gravity = 0
    @flick = false
    @alpha = 1
    @fade = 0
    @color = 0

  # apply resistance

  # gravity down

  # update position based on speed

  # shrink

  # fade out
  Fireworks.Rocket = (x) ->
    Fireworks.Particle.apply this, [
      x: x
      y: Fireworks.SCREEN_HEIGHT
    ]
    @explosionColor = 0


  $(document).mousemove (e) ->
    e.preventDefault()
    Fireworks.mousePos =
      x: e.clientX
      y: e.clientY

  $(document).mousedown (e) ->
    i = 0

    while i < 5
      Fireworks.launchFrom Math.random() * Fireworks.SCREEN_WIDTH * 2 / 3 + Fireworks.SCREEN_WIDTH / 6
      i++

  Fireworks.Particle::update = ->
    @vel.x *= @resistance
    @vel.y *= @resistance
    @vel.y += @gravity
    @pos.x += @vel.x
    @pos.y += @vel.y
    @size *= @shrink
    @alpha -= @fade

  Fireworks.Particle::render = (c) ->
    return  unless @exists()
    c.save()
    c.globalCompositeOperation = "lighter"
    x = @pos.x
    y = @pos.y
    r = @size / 2
    gradient = c.createRadialGradient(x, y, 0.1, x, y, r)
    gradient.addColorStop 0.1, "rgba(255,255,255," + @alpha + ")"
    gradient.addColorStop 0.8, "hsla(" + @color + ", 100%, 50%, " + @alpha + ")"
    gradient.addColorStop 1, "hsla(" + @color + ", 100%, 50%, 0.1)"
    c.fillStyle = gradient
    c.beginPath()
    c.arc @pos.x, @pos.y, (if @flick then Math.random() * @size else @size), 0, Math.PI * 2, true
    c.closePath()
    c.fill()
    c.restore()

  Fireworks.Particle::exists = ->
    @alpha >= 0.1 and @size >= 1

  Fireworks.Rocket:: = new Fireworks.Particle()
  Fireworks.Rocket::constructor = Fireworks.Rocket
  Fireworks.Rocket::explode = ->
    count = Math.random() * 10 + 80
    i = 0

    while i < count
      particle = new Fireworks.Particle(@pos)
      angle = Math.random() * Math.PI * 2

      # emulate 3D effect by using cosine and put more Fireworks.particles in the middle
      speed = Math.cos(Math.random() * Math.PI / 2) * 15
      particle.vel.x = Math.cos(angle) * speed
      particle.vel.y = Math.sin(angle) * speed
      particle.size = 10
      particle.gravity = 0.2
      particle.resistance = 0.92
      particle.shrink = Math.random() * 0.05 + 0.93
      particle.flick = true
      particle.color = @explosionColor
      Fireworks.particles.push particle
      i++

  Fireworks.Rocket::render = (c) ->
    return  unless @exists()
    c.save()
    c.globalCompositeOperation = "lighter"
    x = @pos.x
    y = @pos.y
    r = @size / 2
    gradient = c.createRadialGradient(x, y, 0.1, x, y, r)
    gradient.addColorStop 0.1, "rgba(255, 255, 255 ," + @alpha + ")"
    gradient.addColorStop 1, "rgba(0, 0, 0, " + @alpha + ")"
    c.fillStyle = gradient
    c.beginPath()
    c.arc @pos.x, @pos.y, (if @flick then Math.random() * @size / 2 + @size / 2 else @size), 0, Math.PI * 2, true
    c.closePath()
    c.fill()
    c.restore()

  #start
  setInterval Fireworks.launch, 800
  setInterval Fireworks.loop, 1000 / 50