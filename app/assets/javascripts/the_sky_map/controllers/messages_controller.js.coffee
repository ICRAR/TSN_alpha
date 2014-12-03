TheSkyMap.MessagesIndexController = Ember.ArrayController.extend(TheSkyMap.Paginateble,{
  needs: ['board']
  sortProperties: ['created_at_int']
  sortAscending: false
  selected_filter: ''
  filteredContent: (() ->
    filter = @get('selected_filter')
    content = @get('arrangedContent')
    return content if filter == ''
    content.filter (msg) ->
      if filter  == 'unread'
        msg.get('ack') == false
      else
        filter in msg.get('tag_list')
  ).property('selected_filter','arrangedContent')
  tag_filter_list: (() ->
    list = @get('model.meta.tag_list')
    selected_filter = @get('selected_filter')
    list.map (tag) ->
      selected = (tag == selected_filter)
      {
        name: tag,
        is_selected: selected
      }
  ).property('selected_filter','model.meta.tag_list')
  actions:
    ack_all: () ->
      Ember.$.getJSON "/the_sky_map/messages/ack_all"
    filter_by: (tag) ->
      @set('selected_filter',tag)
      @store.find('message', {tag_filter: tag, page: @get('page'), per_page: @get('per_page')})

})

TheSkyMap.MessageController = Ember.ObjectController.extend
  needs: ['currentPlayer']
  actions:
    ack_msg: () ->
      unread_msg_count = @get('controllers.currentPlayer.content.unread_msg_count')
      @set('controllers.currentPlayer.content.unread_msg_count', unread_msg_count - 1)
      @set('ack',true)
      @get('model').save()
