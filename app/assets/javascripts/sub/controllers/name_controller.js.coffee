TheSkyMap.NameController = Ember.ObjectController.extend
  needs: ['currentProfile']
  name: 'Alex'
  actions:
    default: () ->
      @set 'name', 'Alex'

