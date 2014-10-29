TheSkyMap.MessagesIndexController = Ember.ArrayController.extend(TheSkyMap.Paginateble,{
  needs: ['board']
  sortProperties: ['created_at_int'],
  sortAscending: false
})

TheSkyMap.MessageController = Ember.ObjectController.extend
  needs: ['currentPlayer']
  actions:
    ack_msg: () ->
      unread_msg_count = @get('controllers.currentPlayer.content.unread_msg_count')
      @set('controllers.currentPlayer.content.unread_msg_count', unread_msg_count - 1)
      @set('ack',true)
      @get('model').save()
