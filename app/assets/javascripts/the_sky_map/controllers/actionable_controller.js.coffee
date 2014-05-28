TheSkyMap.ActionableController = Ember.ObjectController.extend
  sorted_actions: (() ->
    all_actions = @get('actions')
    Ember.ArrayProxy.createWithMixins Ember.SortableMixin, {
      sortProperties: ['queued_at_time']
      sortAscending: false
      content: all_actions
    }
  ).property('actions')
  actions:
    perform_action: (action_name) ->
      store = @store
      token = $("meta[name=\"csrf-token\"]").attr("content")
      ship_path = store.adapterFor(this).buildURL('ship',@.get('id'))
      action_path = "#{ship_path}/actions"
      actionable = @get('content')
      $.post(action_path,
        {
          action_name: action_name
        },
        (data) ->
          store.pushPayload('action', data)
          new_action = store.getById('action', data.action.id)
          actionable.get('actions').addObject(new_action)
          actionable.reload()
      )
