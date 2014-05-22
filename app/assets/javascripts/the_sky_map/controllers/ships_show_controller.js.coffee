TheSkyMap.ShipsShowController = Ember.ObjectController.extend
  needs: ['board']
  actions:
    show_on_map: () ->
      quad_id = @get('quadrant.id')
      @get('controllers.board').send('transistion_to_quadrant', quad_id)