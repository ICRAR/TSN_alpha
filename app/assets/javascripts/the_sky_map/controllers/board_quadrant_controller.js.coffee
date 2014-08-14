TheSkyMap.BoardQuadrantController = Ember.ObjectController.extend
  needs: ['board']
  xy_zoomed_in: (() ->
    @get('controllers.board.xy_zoomed_in')
  ).property('controllers.board.xy_zoomed_in')
  actions:
    click_me: () ->
      @transitionToRoute('quadrants.show', @get('id'))