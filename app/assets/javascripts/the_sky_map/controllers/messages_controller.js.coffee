TheSkyMap.MessagesIndexController = Ember.ArrayController.extend(TheSkyMap.Paginateble,{
  needs: ['board']
  sortProperties: ['created_at_int']
  sortAscending: false
  actions:
    ack_all: () ->
      Ember.$.getJSON "/the_sky_map/messages/ack_all"
})

TheSkyMap.MessageController = Ember.ObjectController.extend
  needs: ['currentPlayer']
  actions:
    ack_msg: () ->
      unread_msg_count = @get('controllers.currentPlayer.content.unread_msg_count')
      @set('controllers.currentPlayer.content.unread_msg_count', unread_msg_count - 1)
      @set('ack',true)
      @get('model').save()
