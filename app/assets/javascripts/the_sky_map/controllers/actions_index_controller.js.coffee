TheSkyMap.ActionsIndexController = Ember.ArrayController.extend(TheSkyMap.Paginateble,{

  filter_running_only: false
  filteredContent: (() ->
    filter_running_only = @get('filter_running_only')
    content = @get('content')
    return content unless filter_running_only
    content.filter (action) ->
      action.get('current_state') == 'running' || action.get('current_state') == 'queued_next'
  ).property('filter_running_only','content')
  actions:
    filter_by_running_only: () ->
      @set('filter_running_only',true)
      @store.find('action', {only_running: true, page: @get('page'), per_page: @get('per_page')})
    clear_filter: () ->
      @set('filter_running_only',false)
      @store.find('action', {only_running: false, page: @get('page'), per_page: @get('per_page')})
})