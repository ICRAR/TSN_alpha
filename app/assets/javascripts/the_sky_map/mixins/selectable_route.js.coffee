TheSkyMap.SelectableRoute = Ember.Mixin.create
  afterModel: (model,transition) ->
    new_id = model.get('location').quadrant_id
    board_controller = @controllerFor('board')
    current_id = board_controller.get('selected_quadrant_id')
    unless current_id == 0
      @store.find('quadrant',current_id).then((quadrant) ->
        quadrant.set('is_selected',false)
      )
    @store.find('quadrant',new_id).then((quadrant) ->
      quadrant.set('is_selected',true)
    )
    board_controller.set('selected_quadrant_id',new_id)
  deactivate: () ->
    board_controller = @controllerFor('board')
    current_id = board_controller.get('selected_quadrant_id')
    unless current_id == 0
      @store.find('quadrant',current_id).then((quadrant) ->
        quadrant.set('is_selected',false)
      )
    board_controller.set('selected_quadrant_id',0)