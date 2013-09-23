# Be sure to restart your server when you modify this file.

Tsn::Application.config.session_store :cookie_store, key: '_tsn_session', :domain => APP_CONFIG['cookie_site_host']

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Tsn::Application.config.session_store :active_record_store
