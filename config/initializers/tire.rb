Tire.configure do
  url(APP_CONFIG['elastic_search_host'])  if  APP_CONFIG['elastic_search_host']
end