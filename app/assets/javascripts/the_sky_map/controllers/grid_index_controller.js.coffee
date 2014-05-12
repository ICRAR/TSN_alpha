TheSkyMap.GridIndexController = Ember.ArrayController.extend
  needs: ['currentProfile']
  init: ->
    @_super()
    @set 'x_center', @get('controllers.currentProfile.content.base_x')
    @set 'y_center', @get('controllers.currentProfile.content.base_y')
    @set 'z_center', @get('controllers.currentProfile.content.base_z')
    @.get('store').find('grid',{
      x_min: @.get('x_min')
      x_max: @.get('x_max')
      y_min: @.get('y_min')
      y_max: @.get('y_max')
      z_min: @.get('z_min')
      z_max: @.get('z_max')
    })
  x_center: 1
  y_center: 1
  z_center: 1
  xy_zoom: 2
  z_zoom: 2
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
  grids_layers:(() ->
    c = @
    [@.get('z_min')..@.get('z_max')].map (z) ->
      {
        z: z
        rows: [c.get('y_min')..c.get('y_max')].map (y) ->
          grids = c.get('store').filter(TheSkyMap.Grid, (grid) ->
            grid.get('y') == y && grid.get('z') == z && grid.get('x') >= c.get('x_min') && grid.get('x') <= c.get('x_max')
          )
          gridsArray = Ember.ArrayProxy.createWithMixins Ember.SortableMixin, {
            sortProperties: ['x']
            sortAscending: true
            content: grids
          }
          {
            y: y
            grids: gridsArray
          }
      }
  ).property('x_min','x_max','y_min','y_max','z_min','z_max')
  actions:
    scroll_x_p: () ->
      @.get('store').find(TheSkyMap.Grid,{
        x_min: @.get('x_max') + 1
        x_max: @.get('x_max') + 1
        y_min: @.get('y_min')
        y_max: @.get('y_max')
        z_min: @.get('z_min')
        z_max: @.get('z_max')
      })
      @.set('x_center', @.get('x_center') + 1)
    scroll_x_n: () ->
      @.get('store').find(TheSkyMap.Grid,{
        x_min: @.get('x_min') - 1
        x_max: @.get('x_min') - 1
        y_min: @.get('y_min')
        y_max: @.get('y_max')
        z_min: @.get('z_min')
        z_max: @.get('z_max')
      })
      @.set('x_center', @.get('x_center') - 1)
    scroll_y_p: () ->
      @.get('store').find(TheSkyMap.Grid,{
        x_min: @.get('x_min')
        x_max: @.get('x_max')
        y_min: @.get('y_max') + 1
        y_max: @.get('y_max') + 1
        z_min: @.get('z_min')
        z_max: @.get('z_max')
      })
      @.set('y_center', @.get('y_center') + 1)
    scroll_y_n: () ->
      @.get('store').find(TheSkyMap.Grid,{
        x_min: @.get('x_min')
        x_max: @.get('x_max')
        y_min: @.get('y_min') - 1
        y_max: @.get('y_min') - 1
        z_min: @.get('z_min')
        z_max: @.get('z_max')
      })
      @.set('y_center', @.get('y_center') - 1)
    scroll_z_p: () ->
      @.get('store').find(TheSkyMap.Grid,{
        x_min: @.get('x_min')
        x_max: @.get('x_max')
        y_min: @.get('y_min')
        y_max: @.get('y_max')
        z_min: @.get('z_max') + 1
        z_max: @.get('z_max') + 1
      })
      @.set('z_center', @.get('z_center') + 1)
    scroll_z_n: () ->
      @.get('store').find(TheSkyMap.Grid,{
        x_min: @.get('x_min')
        x_max: @.get('x_max')
        y_min: @.get('y_min')
        y_max: @.get('y_max')
        z_min: @.get('z_min') - 1
        z_max: @.get('z_min') - 1
      })
      @.set('z_center', @.get('z_center') - 1)




