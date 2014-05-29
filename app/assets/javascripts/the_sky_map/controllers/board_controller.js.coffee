TheSkyMap.BoardController = Ember.ArrayController.extend
  needs: ['currentPlayer']
  init: ->
    @_super()
    @set 'x_center', @get('controllers.currentPlayer.content.home_x')
    @set 'y_center', @get('controllers.currentPlayer.content.home_y')
    @set 'z_center', @get('controllers.currentPlayer.content.home_z')
    @send('refresh_view')
  x_center: 1
  y_center: 1
  z_center: 1
  xy_zoom: 3
  xy_zoomed_in: (() ->
    @get('xy_zoom') == 2
  ).property('xy_zoom')
  z_zoom: 1
  x_max: (() ->
    @.get('x_center') + (@.get('xy_zoom') - 1)
  ).property('x_center','xy_zoom')
  x_min: (() ->
    @.get('x_center') - (@.get('xy_zoom') - 1)
  ).property('x_center','xy_zoom')
  y_max: (() ->
    @.get('y_center') + (@.get('xy_zoom') - 1)
  ).property('y_center','xy_zoom')
  y_min: (() ->
    @.get('y_center') - (@.get('xy_zoom') - 1)
  ).property('y_center','xy_zoom')
  z_max: (() ->
    @.get('z_center') + (@.get('z_zoom') - 1)
  ).property('z_center','z_zoom')
  z_min: (() ->
    @.get('z_center') - (@.get('z_zoom') - 1)
  ).property('z_center','z_zoom')
  xs: (( ->
    [@get('x_min')..@get('x_max')]
  )).property('x_min','x_max')
  quadrants_layers:(() ->
    c = @
    [@.get('z_min')..@.get('z_max')].map (z) ->
      {
      z: z
      rows: [c.get('y_min')..c.get('y_max')].map (y) ->
        {
          y:y
          quadrants: [c.get('x_min')..c.get('x_max')].map (x) ->
            quadrantsArray = c.get('store').filter(TheSkyMap.Quadrant, (quadrant) ->
              quadrant.get('y') == y && quadrant.get('z') == z && quadrant.get('x') == x
            )
            {
              x: x
              quadrant_final: quadrantsArray
            }
        }
      }
  ).property('x_min','x_max','y_min','y_max','z_min','z_max')
  actions:
    refresh_view: () ->
      @.get('store').find('quadrant',{
        x_min: @.get('x_min')
        x_max: @.get('x_max')
        y_min: @.get('y_min')
        y_max: @.get('y_max')
        z_min: @.get('z_min')
        z_max: @.get('z_max')
      })
    zoom_1: () ->
      @.set('xy_zoom', 2)
      @send('refresh_view')
    zoom_2: () ->
      @.set('xy_zoom', 3)
      @send('refresh_view')
    transistion_to_quadrant: (quadrant_id) ->
      quad = @.get('store').getById('quadrant', quadrant_id)
      pos = {
        x: quad.get('x')
        y: quad.get('y')
        z: quad.get('z')
      }
      @send('scroll_to_position', pos)
      @transitionToRoute('quadrants.show', quad)
    scroll_to_position: (pos) ->
      @set 'x_center', pos.x
      @set 'y_center', pos.y
      @set 'z_center', pos.z
      @send('refresh_view')
    scroll_home: () ->
      pos = {
       x: @get('controllers.currentPlayer.content.home_x')
       y: @get('controllers.currentPlayer.content.home_y')
       z: @get('controllers.currentPlayer.content.home_z')
      }
      @send('scroll_to_position', pos)
    scroll_x_p: () ->
      @.get('store').find(TheSkyMap.Quadrant,{
        x_min: @.get('x_max') + 1
        x_max: @.get('x_max') + 1
        y_min: @.get('y_min')
        y_max: @.get('y_max')
        z_min: @.get('z_min')
        z_max: @.get('z_max')
      })
      @.set('x_center', @.get('x_center') + 1)
    scroll_x_n: () ->
      @.get('store').find(TheSkyMap.Quadrant,{
        x_min: @.get('x_min') - 1
        x_max: @.get('x_min') - 1
        y_min: @.get('y_min')
        y_max: @.get('y_max')
        z_min: @.get('z_min')
        z_max: @.get('z_max')
      })
      @.set('x_center', @.get('x_center') - 1)
    scroll_y_p: () ->
      @.get('store').find(TheSkyMap.Quadrant,{
        x_min: @.get('x_min')
        x_max: @.get('x_max')
        y_min: @.get('y_max') + 1
        y_max: @.get('y_max') + 1
        z_min: @.get('z_min')
        z_max: @.get('z_max')
      })
      @.set('y_center', @.get('y_center') + 1)
    scroll_y_n: () ->
      @.get('store').find(TheSkyMap.Quadrant,{
        x_min: @.get('x_min')
        x_max: @.get('x_max')
        y_min: @.get('y_min') - 1
        y_max: @.get('y_min') - 1
        z_min: @.get('z_min')
        z_max: @.get('z_max')
      })
      @.set('y_center', @.get('y_center') - 1)
    scroll_z_p: () ->
      @.get('store').find(TheSkyMap.Quadrant,{
        x_min: @.get('x_min')
        x_max: @.get('x_max')
        y_min: @.get('y_min')
        y_max: @.get('y_max')
        z_min: @.get('z_max') + 1
        z_max: @.get('z_max') + 1
      })
      @.set('z_center', @.get('z_center') + 1)
    scroll_z_n: () ->
      @.get('store').find(TheSkyMap.Quadrant,{
        x_min: @.get('x_min')
        x_max: @.get('x_max')
        y_min: @.get('y_min')
        y_max: @.get('y_max')
        z_min: @.get('z_min') - 1
        z_max: @.get('z_min') - 1
      })
      @.set('z_center', @.get('z_center') - 1)




