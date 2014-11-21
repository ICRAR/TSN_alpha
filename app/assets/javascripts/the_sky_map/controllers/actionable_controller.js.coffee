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
      save_this = this
      actionable = @get('content')
      model_name = actionable.get('constructor.typeKey')
      actionable_path = store.adapterFor(this).buildURL(model_name,@.get('id'))
      action_path = "#{actionable_path}/actions"
      $.post(action_path,
        {
          action_name: action_name
        },
        (data) ->
          store.pushPayload('action', data)
          new_action = store.getById('action', data.action.id)
          actionable.get('actions').addObject(new_action)
          save_this.send('update_actions')

      )
    update_actions: () ->
      store = @store
      actionable = @get('content')
      model_name = actionable.get('constructor.typeKey')
      actionable_path = store.adapterFor(this).buildURL(model_name,@.get('id'))
      action_update_path = "#{actionable_path}/game_actions_available"
      $.get(action_update_path,
        {},
      (data) ->
        for action in data['actions']
          store.update('action',action)
        #store.pushPayload('action', {actions: data['actions']})
        store.update(model_name,data[model_name])
        #store.pushPayload('action', data)
        #actionable = action.get('actionable')
        #actionable.reload()
      )
