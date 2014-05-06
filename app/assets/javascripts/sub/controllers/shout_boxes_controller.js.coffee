TheSkyMap.ShoutBoxesController = Ember.ArrayController.extend
  per_page: 3
  page: 1
  actions:
    addShoutBox: (msg) ->
      newShoutBox = this.store.createRecord 'shout_box',
        msg: msg
      newShoutBox.save()
