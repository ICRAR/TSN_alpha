TheSkyMap.BoardController = Ember.ArrayController.extend  TheSkyMap.isLoadedable,
  needs: ['currentPlayer']
  isLoadedFirst: false
  init: ->
    @_super()
    @set 'x_center', @get('controllers.currentPlayer.content.home_x')
    @set 'y_center', @get('controllers.currentPlayer.content.home_y')
    @send('refresh_view')
  x_center: 1
  y_center: 1
  xy_zoom: 3
  xy_zoomed_in: (() ->
    @get('xy_zoom') == 2
  ).property('xy_zoom')
  xy_col_size: (() ->
    xy_zoom = @get('xy_zoom')
    if xy_zoom == 2
      'col-md-4'
    else if  xy_zoom == 3
      'col-md-2'
    else if  xy_zoom == 6
      'col-md-1'
  ).property('xy_zoom')
  xy_zoom_class: (() ->
    "zoom_#{@get('xy_zoom')}"
  ).property('xy_zoom')
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
  xs: (( ->
    [@get('x_min')..@get('x_max')]
  )).property('x_min','x_max')
  selected_quadrant_id: 0
  quadrants_rows:(() ->
    c = @
    [c.get('y_min')..c.get('y_max')].map (y) ->
      {
        y:y
        quadrants: [c.get('x_min')..c.get('x_max')].map (x) ->
          quadrantsArray = c.get('store').filter(TheSkyMap.Quadrant, (quadrant) ->
            quadrant.get('y') == y && quadrant.get('x') == x
          )
          {
            x: x
            quadrant_final: quadrantsArray
          }
      }
  ).property('x_min','x_max','y_min','y_max')
  actions:
    refresh: () ->
      @send('refresh_view')
    refresh_view: () ->
      @set('isLoaded', false)
      save_this = @
      @.get('store').find('quadrant',{
        x_min: @.get('x_min')
        x_max: @.get('x_max')
        y_min: @.get('y_min')
        y_max: @.get('y_max')
      }).then ()->
        save_this.set('isLoaded', true)
        save_this.set('isLoadedFirst', true)
    zoom_1: () ->
      @.set('xy_zoom', 3)
      @send('refresh_view')
    zoom_2: () ->
      @.set('xy_zoom', 4)
      @send('refresh_view')
    zoom_3: () ->
      @.set('xy_zoom', 5)
      @send('refresh_view')
    transistion_to_quadrant: (quadrant_id) ->
      quad = @.get('store').getById('quadrant', quadrant_id)
      pos = {
        x: quad.get('x')
        y: quad.get('y')
      }
      @send('scroll_to_position', pos)
      #@transitionToRoute('quadrants.show', quad)
    scroll_to_position: (pos) ->
      #check if we are already at the correct postion
      unless (pos.x == @get('x_center') && pos.y == @get('y_center'))
        @set 'x_center', pos.x
        @set 'y_center', pos.y
        @send('refresh_view')
    scroll_home: () ->
      pos = {
       x: @get('controllers.currentPlayer.content.home_x')
       y: @get('controllers.currentPlayer.content.home_y')
      }
      @send('scroll_to_position', pos)
    scroll_x_p: () ->
      @.get('store').find(TheSkyMap.Quadrant,{
        x_min: @.get('x_max') + 1
        x_max: @.get('x_max') + 1
        y_min: @.get('y_min')
        y_max: @.get('y_max')
      })
      @.set('x_center', @.get('x_center') + 1)
    scroll_x_n: () ->
      @.get('store').find(TheSkyMap.Quadrant,{
        x_min: @.get('x_min') - 1
        x_max: @.get('x_min') - 1
        y_min: @.get('y_min')
        y_max: @.get('y_max')
      })
      @.set('x_center', @.get('x_center') - 1)
    scroll_y_p: () ->
      @.get('store').find(TheSkyMap.Quadrant,{
        x_min: @.get('x_min')
        x_max: @.get('x_max')
        y_min: @.get('y_max') + 1
        y_max: @.get('y_max') + 1
      })
      @.set('y_center', @.get('y_center') + 1)
    scroll_y_n: () ->
      @.get('store').find(TheSkyMap.Quadrant,{
        x_min: @.get('x_min')
        x_max: @.get('x_max')
        y_min: @.get('y_min') - 1
        y_max: @.get('y_min') - 1
      })
      @.set('y_center', @.get('y_center') - 1)




