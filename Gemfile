source 'https://rubygems.org'

gem 'rails', '3.2.11'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

#gem 'pg'     #main db driver
gem 'mysql2', '~>0.3.12b6' #for connecting with nereus db
gem "squeel"

#gems for user auth
gem 'devise'
gem 'devise_invitable', '~> 1.1.0'
gem 'devise-async'
gem 'cancan'

gem 'rails_admin'
gem 'rack-ssl-enforcer'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', :platforms => :ruby
#  gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
#  gem "twitter-bootstrap-rails"
  gem 'uglifier', '>= 1.0.3'
  gem "asset_sync"
end
gem "twitter-bootstrap-rails"
gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS


#general use gems
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem "ckeditor"        #note requries imageMagick for image uploads
gem "paperclip"
gem 'aws-sdk', '~> 1.5.7'
gem 'linguistics'
gem "possessive"
#gem 'will_paginate', '~> 3.0.0'
gem 'kaminari', git: "git://github.com/amatsuda/kaminari.git"
gem 'turbolinks'
gem 'jquery-turbolinks'
gem 'fancybox2-rails', '~> 0.2.4'
gem 'paper_trail'
gem 'tire'
gem 'acts-as-taggable-on'
gem 'rmagick'
gem 'voruby'
gem 'globalize', '~> 3.0.4'
gem 'i18n-js'
gem 'sanitize'
gem 'mailboxer'
gem "messengerjs-rails", "~> 1.3.6"
gem 'metamagic'
gem 'talk_like_a_pirate'
gem 'premailer-rails'
gem 'closure_tree'
gem 'redcarpet'

gem 'delayed_job_active_record'
gem 'daemons'


gem 'mail_form'
gem 'simple_form'
gem 'country_select'

#json builder
gem 'rabl'
# Also add either `oj` or `yajl-ruby` as the JSON parser
gem 'oj'


gem 'turnout'

group :development do
  gem 'rack-mini-profiler'
  gem 'flamegraph'
  gem 'rails-footnotes', '>= 3.7.9'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'railroady'
  gem 'rename'
  gem "mail_view", "~> 2.0.1"
  gem 'webrick', '~> 1.3.1'
end

group :profile, :development do
  gem 'thin'
end

group :profile do
  gem 'ruby-prof'
end

#Gems required for testing
group :development, :test do
  gem 'rspec-rails'
  #gem 'factory_girl_rails'
  gem 'fabrication'
  gem 'faker'
  gem 'debugger', "~> 1.6.2"
  gem 'debugger-xml', "~> 0.3.3"
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'capybara-webkit'
  gem 'capybara-screenshot'
  gem 'database_cleaner'
#  gem 'guard-rspec'
  gem 'launchy'
  gem 'zeus', '~>0.13.4.pre2'
  gem 'simplecov', :require => false

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

gem 'newrelic_rpm'
gem 'google-analytics-rails'


#not loaded when running rails used to make generating cron jobs easy
gem 'whenever', :require => false
