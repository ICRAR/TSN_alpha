TheSkyMap.QuadrantShowController = Ember.ObjectController.extend
  needs: ['board']
  has_galaxy: (() ->
      @get('galaxy_id') > 0
    ).property('galaxy_id')
  galaxy_link: (() ->
      "/galaxies/#{@get('galaxy_id')}"
    ).property('galaxy_id')
  actions:
    scroll_to_home: () ->
      pos = {
        x: @get('x')
        y: @get('y')
        z: @get('z')
      }
      @get('controllers.board').send('scroll_to_position', pos)
    reload: () ->
      @.get('model').reload()