# http://emberjs.com/guides/models/using-the-store/

TheSkyMap.Store = DS.Store.extend
  # Override the default adapter with the `DS.ActiveModelAdapter` which
  # is built to work nicely with the ActiveModel::Serializers gem.
  revision: 12,
  #adapter: '_ams'
DS.RESTAdapter.reopen
  namespace: 'sub'