TheSkyMap.ShipShowController = TheSkyMap.ActionableController.extend
  needs: ['board']
  actions:
    show_on_map: () ->
      quad_id = @get('quadrant.id')
      @get('controllers.board').send('transistion_to_quadrant', quad_id)
    reload: () ->
      save_this = @
      @.get('model').reload().then(() ->
        save_this.send('update_actions')
      ).catch((reason) ->
        if reason.name == TheSkyMap.UnfoundError().name
          save_this.transitionToRoute('home')
          false
        else
          true
      )