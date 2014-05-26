TheSkyMap.ShipsController = Ember.ObjectController.extend
  columns: Ember.computed ->
    columnNames = ['login', 'attack', 'Speed', 'Mine?']
    columns = columnNames.map (key, index) ->
      Ember.Table.ColumnDefinition.create
        columnWidth: 150
        headerCellName: key.w()
        contentPath: key
    columns.unshift avatar
    columns
