TheSkyMap.CurrentProfileController = Ember.ObjectController.extend
  content: null
  retrieveCurrentUser: ->
    controller = this
    Ember.$.getJSON "/sub/ember/current_profile", (data) ->
      controller.get('store').pushPayload 'currentProfile', data
      currentProfile =  controller.get('store').find(data.current_profile.id)
      controller.set "content", currentProfile
  init: ->
    data = $('#data').data('currentProfile').current_profile
    @.get('store').push 'current_profile', data
    currentProfile = @.get('store').getById('current_profile', data.id)
    @.set "content", currentProfile
