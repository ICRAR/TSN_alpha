TheSkyMap.Paginateble = Ember.Mixin.create
  queryParams: ['page', 'per_page']
  page: 1
  per_page: 10
  pagesObject: (() ->
    model = @get('model')
    name = Ember.Inflector.inflector.pluralize(model.type.toString().split('.').pop())
    {
    totalPages: model.meta.pagination.total_pages
    activePage: @get 'page'
    count: model.meta.pagination.count
    totalCount: model.meta.pagination.total_count
    name: name
    }
  ).property('page', 'model.meta.pagination')

TheSkyMap.PaginateableRouter = Ember.Mixin.create
  queryParams: {
    page: {
      refreshModel: true
    }
  }