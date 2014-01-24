TheSkyMap.EntriesController = Ember.ArrayController.extend
  actions:
    addShoutBox: (name) ->
      TheSkyMap.ShoutBox.createRecord(msg: msg)
      @get('store').commit()
