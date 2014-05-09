TheSkyMap.ShoutBoxController = Ember.ObjectController.extend
  actions:
    editShout: () ->
      this.set('isEditing', true)
    acceptChanges: () ->
      this.set('isEditing', false)
      this.get('model').save()
    removeShout: () ->
      shout = this.get('model')
      shout.deleteRecord()
      shout.save()

  isEditing: false
