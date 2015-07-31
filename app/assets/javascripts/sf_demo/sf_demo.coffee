class SFRenderer
  constructor: (@width, @height,@data_location) ->
    #create base objects and set defaults
    @renderer = new (THREE.WebGLRenderer)({
      antialias: true,
      alpha: true,
    })
    @renderer.setSize @width, @height

    @menu = $('#sf_render_menu')
    $('#graph').append @renderer.domElement


    #@renderer.setClearColorHex 0xFFFFFF, 0.0
    @camera = new (THREE.PerspectiveCamera)(45, @width / @height, 1, 10000)
    @camera_zoom_default = 200
    @camera_theta_default = Math.PI * 2
    @camera_phi_default = Math.PI / 2
    @camera_zoom = @camera_zoom_default
    @camera_theta = @camera_theta_default
    @camera_phi = @camera_phi_default
    @update_camera()
    @scene = new THREE.Scene()
    @scatterPlot = new (THREE.Object3D)
    @scene.add @scatterPlot
    @scatterPlot.rotation.y = 0
    @plot_data = {}
    @param_list = []
    @format = d3.format('+.3f')

    #start run
    @paused = false
    @data_loaded = false
    @load_data()

  update_camera: () ->
    x = @camera_zoom * Math.cos(@camera_theta) * Math.sin(@camera_phi)
    y = @camera_zoom * Math.sin(@camera_theta) * Math.sin(@camera_phi)
    z = @camera_zoom * Math.cos(@camera_phi)
    @camera.position.z = x
    @camera.position.x = y
    @camera.position.y = z
    #console.log "camera: th: #{@camera_theta}, ph: #{@camera_phi}, zo: #{@camera_zoom}, x:#{x},y:#{y},z:#{z}"


  load_data: () ->
    save_this = @
    d3.json(@data_location, (data, error) ->
      for d in data.points
        p_id = d.ParameterNumber
        if !save_this.plot_data[p_id]?
          save_this.plot_data[p_id] = []
          save_this.param_list.push p_id
        x = parseFloat(d.RA)
        y = parseFloat(d.DEC)
        z = parseFloat(d.freq) / 1000 / 1000 / 1000
        save_this.plot_data[p_id].push
          x: x
          y: y
          z: z

      save_this.build_graph()
      save_this.add_controls()
      save_this.add_points()
      save_this.set_window_fncs()
      save_this.animating = false
      save_this.data_loaded = true

      save_this.animate (new Date).getTime()
    )

  build_graph: () ->
    all_points = []
    for p_id, points of @plot_data
      all_points.push points...
    xExent = d3.extent(all_points, (d) ->
      d.x
    )
    yExent = d3.extent(all_points, (d) ->
      d.y
    )
    zExent = d3.extent(all_points, (d) ->
      d.z
    )
    vpts =
      xMax: xExent[1]
      xCen: (xExent[1] + xExent[0]) / 2
      xMin: xExent[0]
      yMax: yExent[1]
      yCen: (yExent[1] + yExent[0]) / 2
      yMin: yExent[0]
      zMax: zExent[1]
      zCen: (zExent[1] + zExent[0]) / 2
      zMin: zExent[0]
    colour = d3.scale.category20c()
    @xScale = d3.scale.linear().domain(xExent).range([
      -50
      50
    ])
    @yScale = d3.scale.linear().domain(yExent).range([
      -50
      50
    ])
    @zScale = d3.scale.linear().domain(zExent).range([
      -50
      50
    ])

    lineMat = new (THREE.LineBasicMaterial)(
      color: 0x000000
      lineWidth: 1)
    #add Front box
    square_pos_x = new (THREE.Geometry)
    square_pos_x.vertices.push(
      v(@xScale(vpts.xMin), @yScale(vpts.yMin), @zScale(vpts.zMax)),
      v(@xScale(vpts.xMin), @yScale(vpts.yMax), @zScale(vpts.zMax)),
      v(@xScale(vpts.xMax), @yScale(vpts.yMax), @zScale(vpts.zMax)),
      v(@xScale(vpts.xMax), @yScale(vpts.yMin), @zScale(vpts.zMax)),
      v(@xScale(vpts.xMin), @yScale(vpts.yMin), @zScale(vpts.zMax)),
    )
    line = new (THREE.Line)(square_pos_x, lineMat)
    @scatterPlot.add line
    #add Back box
    square_neg_x = new (THREE.Geometry)
    square_neg_x.vertices.push(
      v(@xScale(vpts.xMin), @yScale(vpts.yMin), @zScale(vpts.zMin)),
      v(@xScale(vpts.xMin), @yScale(vpts.yMax), @zScale(vpts.zMin)),
      v(@xScale(vpts.xMax), @yScale(vpts.yMax), @zScale(vpts.zMin)),
      v(@xScale(vpts.xMax), @yScale(vpts.yMin), @zScale(vpts.zMin)),
      v(@xScale(vpts.xMin), @yScale(vpts.yMin), @zScale(vpts.zMin)),
    )
    line = new (THREE.Line)(square_neg_x, lineMat)
    @scatterPlot.add line
    #add remaining lines
    extra_lines = new (THREE.Geometry)
    extra_lines.vertices.push(
      v(@xScale(vpts.xMin), @yScale(vpts.yMin), @zScale(vpts.zMin)),#line 1
      v(@xScale(vpts.xMin), @yScale(vpts.yMin), @zScale(vpts.zMax)),
      v(@xScale(vpts.xMax), @yScale(vpts.yMin), @zScale(vpts.zMin)),#line 2
      v(@xScale(vpts.xMax), @yScale(vpts.yMin), @zScale(vpts.zMax)),
      v(@xScale(vpts.xMax), @yScale(vpts.yMax), @zScale(vpts.zMin)),#line 3
      v(@xScale(vpts.xMax), @yScale(vpts.yMax), @zScale(vpts.zMax)),
      v(@xScale(vpts.xMin), @yScale(vpts.yMax), @zScale(vpts.zMin)),#line 4
      v(@xScale(vpts.xMin), @yScale(vpts.yMax), @zScale(vpts.zMax)),
    )
    line = new (THREE.Line)(extra_lines, lineMat)
    line.type = THREE.Lines
    @scatterPlot.add line
    #add axis labels
    titleX = @createText2D('-RA')
    titleX.position.x = @xScale(vpts.xMin) - 12
    titleX.position.y = 5
    @scatterPlot.add titleX
    valueX = @createText2D(@format(xExent[0]))
    valueX.position.x = @xScale(vpts.xMin) - 12
    valueX.position.y = -5
    @scatterPlot.add valueX
    titleX = @createText2D('RA')
    titleX.position.x = @xScale(vpts.xMax) + 12
    titleX.position.y = 5
    @scatterPlot.add titleX
    valueX = @createText2D(@format(xExent[1]))
    valueX.position.x = @xScale(vpts.xMax) + 12
    valueX.position.y = -5
    @scatterPlot.add valueX
    titleY = @createText2D('-Dec')
    titleY.position.y = @yScale(vpts.yMin) - 5
    @scatterPlot.add titleY
    valueY = @createText2D(@format(yExent[0]))
    valueY.position.y = @yScale(vpts.yMin) - 15
    @scatterPlot.add(valueY)
    titleY = @createText2D('Dec')
    titleY.position.y = @yScale(vpts.yMax) + 15
    @scatterPlot.add titleY
    valueY = @createText2D(@format(yExent[1]))
    valueY.position.y = @yScale(vpts.yMax) + 5
    @scatterPlot.add(valueY)
    titleZ = @createText2D('-Freq (Ghz) ' + @format(zExent[0]))
    titleZ.position.z = @zScale(vpts.zMin) + 2
    @scatterPlot.add titleZ
    titleZ = @createText2D('Freq (Ghz) ' + @format(zExent[1]))
    titleZ.position.z = @zScale(vpts.zMax) + 2
    @scatterPlot.add titleZ

  add_points: () ->
    colour = d3.scale.category20c()
    mat = new (THREE.ParticleBasicMaterial)(
      vertexColors: true
      size: 4)
    pointCount = @plot_data.length
    @pointGeos = {}
    @particl_systems = {}
    i = 0
    for p_id in @param_list
      @pointGeos[p_id] = new (THREE.Geometry)
      pointGeo = @pointGeos[p_id]
      for point in @plot_data[p_id]
        x = @xScale(point.x)
        y = @yScale(point.y)
        z = @zScale(point.z)
        pointGeo.vertices.push new (THREE.Vector3)(x, y, z)
        #console.log @pointGeo.vertices
        #@pointGeo.vertices[i].angle = Math.atan2(z, x);
        #@pointGeo.vertices[i].radius = Math.sqrt(x * x + z * z);
        #@pointGeo.vertices[i].speed = (z / 100) * (x / 100);
        pointGeo.colors.push (new (THREE.Color)).setRGB(hexToRgb(colour(i)).r / 255, hexToRgb(colour(i)).g / 255, hexToRgb(colour(i)).b / 255)
      @particl_systems[p_id] = new (THREE.ParticleSystem)(pointGeo, mat)
      i++
    for p_id, p_s of @particl_systems
      @scatterPlot.add p_s
    @renderer.render @scene, @camera
    paused = false
    last = (new Date).getTime()
    down = false
    sx = 0
    sy = 0

  toggle_param_group: (p_id) ->
    p_s = @particl_systems[p_id]
    p_s.visible = !p_s.visible

  add_controls: () ->
    save_this = @

    #add param toggels
    @menu.append $('<p/>',{
      text: 'Select parameter set:'
    })
    @menu.append $("<ul/>", {
        class: 'list-unstyled'
    })
    for p_id in @param_list
      @add_param_toggle(p_id)
    reset_button = $('<button/>',{
      text:'Reset Camera',
      class: 'btn btn-default',
      type: 'button'
    })

    #add camera reset button
    reset_button.click () ->
      save_this.reset_camera()
    @menu.append reset_button
  add_param_toggle: (p_id) ->
    menu_item = $('<li/>',{
      class: 'selected'
    })
    menu_item.append $('<span/>',{
      class: 'glyphicon glyphicon-ok'
    })
    menu_item.append $('<u/>',{
      text: p_id,
      class: 'btn btn-link'
    })
    save_this = @
    menu_item.click () ->
      save_this.toggle_param_group(p_id)
      menu_item.toggleClass('selected unselected')
      menu_item.find('.glyphicon').toggleClass('glyphicon-ok glyphicon-remove')

    @menu.find('ul').append menu_item

  set_window_fncs: () ->
    save_this = @
    g = @renderer.domElement
    g.onmousedown = (ev) ->
      save_this.onmousedown(ev)
    g.onmouseup = (ev) ->
      save_this.onmouseup(ev)
    g.onmousemove = (ev) ->
      save_this.onmousemove(ev)
    g.onmousewheel = (ev) ->
      ev.preventDefault()
      save_this.onmousewheel(ev)


  onmousedown: (ev) ->
    @down = true
    @sx = ev.clientX
    @sy = ev.clientY
    return

  onmouseup: (ev) ->
    @down = false
    return

  onmousemove: (ev) ->
    if @down
      dx = ev.clientX - @sx
      dy = ev.clientY - @sy
      @camera_theta -= dx * 0.01
      @camera_phi -= dy * 0.01
      @sx += dx
      @sy += dy
      @update_camera()
    return

  onmousewheel: (ev) ->
    new_zoom = @camera_zoom - (ev.wheelDelta * 0.1)
    @camera_zoom = Math.max(1,new_zoom)
    @update_camera()
  reset_camera: () ->
    @camera_zoom = @camera_zoom_default
    @camera_theta = @camera_theta_default
    @camera_phi = @camera_phi_default
    @update_camera()

  animate: (t) ->
    if !@paused
      last = t
      if @animating
        v = @pointGeo.vertices
        i = 0
        while i < v.length
          u = v[i]
          console.log u
          u.angle += u.speed * 0.01
          u.x = Math.cos(u.angle) * u.radius
          u.z = Math.sin(u.angle) * u.radius
          i++
        @pointGeo.__dirtyVertices = true
      @renderer.clear()
      @camera.lookAt @scene.position
      @renderer.render @scene, @camera
    save_this = @
    window.requestAnimationFrame(() ->
      save_this.animate()
    , @renderer.domElement)

  createTextCanvas: (text, color, font, size) ->
    size = size or 16
    canvas = document.createElement('canvas')
    ctx = canvas.getContext('2d')
    fontStr = size + 'px ' + (font or 'Arial')
    ctx.font = fontStr
    @width = ctx.measureText(text).width
    @height = Math.ceil(size)
    canvas.width = @width
    canvas.height = @height
    ctx.font = fontStr
    ctx.fillStyle = color or 'black'
    ctx.fillText text, 0, Math.ceil(size * 0.8)
    canvas

  createText2D: (text, color, font, size, segW, segH) ->
    canvas = @createTextCanvas(text, color, font, size)
    plane = new (THREE.PlaneGeometry)(canvas.width, canvas.height, segW, segH)
    tex = new (THREE.Texture)(canvas)
    tex.needsUpdate = true
    planeMat = new (THREE.MeshBasicMaterial)(
      map: tex
      color: 0xffffff
      transparent: true)
    mesh = new (THREE.Mesh)(plane, planeMat)
    mesh.scale.set 0.5, 0.5, 0.5
    mesh.doubleSided = true
    mesh


#helper Functions

# from http://stackoverflow.com/questions/5623838/rgb-to-hex-and-hex-to-rgb


hexToRgb = (hex) ->
#TODO rewrite with vector output
  result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
  if result
    {
      r: parseInt(result[1], 16)
      g: parseInt(result[2], 16)
      b: parseInt(result[3], 16)
    }
  else
    null

v = (x, y, z) ->
  new (THREE.Vector3)(x, y, z)


#Run
box = $('#graph')
sf = new SFRenderer(box.width(),window.innerHeight - 300,'/misc/sf_demo_data.json')
