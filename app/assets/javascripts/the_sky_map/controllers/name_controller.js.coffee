TheSkyMap.NameController = Ember.ObjectController.extend
  needs: ['currentPlayer']
  name: 'Alex'
  init: () ->
    @set 'name', @get('controllers.currentPlayer.content.name')
  actions:
    default: () ->
      @set 'name', 'Alex'

