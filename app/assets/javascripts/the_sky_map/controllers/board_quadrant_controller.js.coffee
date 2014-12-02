TheSkyMap.BoardQuadrantController = Ember.ObjectController.extend
  needs: ['board']
  xy_zoomed_in: (() ->
    @get('controllers.board.xy_zoomed_in')
  ).property('controllers.board.xy_zoomed_in')
  has_galaxy: (() ->
    @get('galaxy_id') > 0
  ).property('galaxy_id')
  actions:
    click_me: () ->
      @transitionToRoute('quadrant.show', @get('id'))