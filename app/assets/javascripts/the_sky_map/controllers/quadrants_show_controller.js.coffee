TheSkyMap.QuadrantsShowController = Ember.ObjectController.extend
  needs: ['board']
  actions:
    scroll_to_home: () ->
      pos = {
        x: @get('x')
        y: @get('y')
        z: @get('z')
      }
      @get('controllers.board').send('scroll_to_position', pos)