source 'https://rubygems.org'

gem 'rails', '3.2.11'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'pg'     #main db driver
gem 'mysql2' #for connecting with nereus db

#gems for user auth
gem 'devise'
gem 'cancan'

gem 'rails_admin'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
  gem "asset_sync"
end

#general use gems
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem "ckeditor"        #note requries imageMagick for image uploads
gem "paperclip"
gem 'aws-sdk', '~> 1.5.7'
gem 'linguistics'
gem "possessive"
#gem 'will_paginate', '~> 3.0.0'
gem 'kaminari'

gem 'pg_search'
gem 'mail_form'
gem 'simple_form'

#json builder
gem 'rabl'
# Also add either `oj` or `yajl-ruby` as the JSON parser
gem 'oj'

group :development do
  gem 'rack-mini-profiler'
  gem 'rails-footnotes', '>= 3.7.9'

end

#Gems required for testing
group :development, :test do
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'faker'
end

group :test do
  gem 'capybara'
#  gem 'guard-rspec'
  gem 'launchy'
end


#for use with importing data from external sites
gem 'nokogiri'
gem 'upsert'

#stats tracking
gem "statsd-ruby", :require => "statsd"

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'


#not loaded when running rails used to make generating cron jobs easy
gem 'whenever', :require => false
#gem 'spring', :git => 'git://github.com/jonleighton/spring.git', :require => false