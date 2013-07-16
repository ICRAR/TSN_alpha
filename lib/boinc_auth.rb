module BoincAuth
  module Devise
    module Strategies
      class FromSession < ::Devise::Strategies::Base
        def valid?
          # this strategy is only valid if the user does not have an account in the local db
          user = User.where(["lower(username) = :value OR lower(email) = :value", { :value => params[:login] }]).first
          APP_CONFIG[:use_boinc_auth] && user.nil?
        end
        def authenticate!
         #lookup user in boincDB

          # check if their vaild
          if session_data['error']
            # session lookup failed so fail authentication with message from api
            fail!(session_data['error'])
          else
            # we got some valid user data
            success!(User.find(session_data['user_id']))
          end
        end
      end
    end
  end
end