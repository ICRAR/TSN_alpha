TheSkyMap.MiniMapController = Ember.ArrayController.extend
  needs: ['currentPlayer','board']
  init: ->
    @_super()
    @send('refresh_view')
  view_widow_style: (() ->

    map_x_min = @get('controllers.currentPlayer.mini_map_x_min')
    map_x_max = @get('controllers.currentPlayer.mini_map_x_max')
    map_y_min = @get('controllers.currentPlayer.mini_map_y_min')
    map_y_max = @get('controllers.currentPlayer.mini_map_y_max')

    x_min = Math.max(@get('controllers.board.x_min'),map_x_min)
    x_max = Math.min(@get('controllers.board.x_max'),map_x_max)
    y_min = Math.max(@get('controllers.board.y_min'),map_y_min)
    y_max = Math.min(@get('controllers.board.y_max'),map_y_max)
    width = (x_max - x_min + 1) * 16
    height = (y_max - y_min + 1) * 16
    top = (y_min - 1) * 16
    left = (x_min - 1) * 16
    "width: #{width}px; height: #{height}px; top: #{top}px; left: #{left}px;"
  ).property('controllers.board.x_min','controllers.board.x_max',
    'controllers.board.y_min','controllers.board.y_max', 'controllers.currentPlayer.player_options')
  mini_map_rows:(() ->
    c = @
    x_min = @get('controllers.currentPlayer.mini_map_x_min')
    x_max = @get('controllers.currentPlayer.mini_map_x_max')
    y_min = @get('controllers.currentPlayer.mini_map_y_min')
    y_max = @get('controllers.currentPlayer.mini_map_y_max')
    [y_min..y_max].map (y) ->
      {
        y:y
        quadrants: [x_min..x_max].map (x) ->
          quadrantsArray = c.get('store').filter(TheSkyMap.MiniQuadrant, (quadrant) ->
            quadrant.get('y') == y && quadrant.get('x') == x
          )
          {
            x: x
            quadrant_final: quadrantsArray
          }
      }
  ).property('controllers.currentPlayer.player_options')
  actions:
    move_view: (x,y) ->
      pos = {
        x: x
        y: y
      }
      @get('controllers.board').send('scroll_to_position', pos)
    refresh_view: () ->
      @.get('store').find('mini_quadrant')

TheSkyMap.MiniMapObjectController = Ember.ObjectController.extend
  needs: ['board']


