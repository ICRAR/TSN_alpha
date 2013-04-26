# Load the rails application
require File.expand_path('../application', __FILE__)
Linguistics.use( :en )

#load secret custom config file
APP_CONFIG = YAML.load_file("#{Rails.root}/config/custom_config.yml")[Rails.env]

# Initialize the rails application
TSNAlpha::Application.initialize!
