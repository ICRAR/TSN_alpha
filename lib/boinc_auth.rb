module BoincAuth
  module Devise
    module Strategies
      class FromBoinc < ::Devise::Strategies::Base
        def valid?
          return false unless (params[:commit] == 'Sign in') || (params[:commit] == 'Log in')
          # this strategy is only valid if the user does not have an account in the local db
          user = User.where(["lower(username) = :value OR lower(email) = :value", { :value => params[:user][:login] }]).first
          APP_CONFIG['use_boinc_auth'] && user.nil?
        end
        def authenticate!
         #lookup user in boincDB
         boinc_user = BoincRemoteUser.auth(params[:user][:login] ,params[:user][:password])
          # check if their vaild
          if boinc_user == false
            #failed to authenticate against the boincdb
            fail!('No user was found with that username and password')
          else
            #They have a vaild boinc account but no skynet account, we need to create a skynet account for them
            #first create new account
            new_user = boinc_user.copy_to_local(params[:user][:password])

            success!(new_user)
          end
        end
      end
    end
  end
end