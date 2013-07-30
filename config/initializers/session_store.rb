# Be sure to restart your server when you modify this file.

TSNAlpha::Application.config.session_store :cookie_store, key: '_TSN_alpha_session', :domain => APP_CONFIG['site_host']

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# TSNAlpha::Application.config.session_store :active_record_store
