TheSkyMap.NameController = Ember.ObjectController.extend
  needs: ['currentProfile']
  name: 'Alex'
  init: () ->
    @set 'name', @get('controllers.currentProfile.content.name')
  actions:
    default: () ->
      @set 'name', 'Alex'

