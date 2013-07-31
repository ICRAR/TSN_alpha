module BoincAuth
  module Devise
    module Strategies
      class FromBoinc < ::Devise::Strategies::Base
        def valid?
          return false unless params[:commit] == 'Sign in'
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
            #puts boinc_user.to_json
            new_user = User.new(
                :email => boinc_user.email_addr,
                :username => boinc_user.name,
                :password => params[:user][:password],
                :password_confirmation => params[:user][:password],
            )
            puts new_user.to_json
            new_user.skip_confirmation!
            new_user.confirmed_at = Time.at(boinc_user.create_time)
            if new_user.save
              profile = new_user.profile
              profile.nickname = boinc_user.name
              profile.use_full_name = false
              profile.country = boinc_user[:country]
              profile.new_profile_step= 2
              profile.save
            end
           #puts new_user.to_json
            #look for boinc_stats_item
            boinc_item = BoincStatsItem.where(:boinc_id => boinc_user.id).first
            if boinc_item.nil?
              #create new item
              boinc_item = BoincStatsItem.create(:boinc_id => id , :credit => boinc_user.total_credit, :RAC => boinc_user.expavg_credit)
            end
            unless boinc_item.nil?
              new_user.profile.general_stats_item.boinc_stats_item = boinc_item
              new_user.profile.general_stats_item.update_credit
            end

            success!(new_user)
          end
        end
      end
    end
  end
end