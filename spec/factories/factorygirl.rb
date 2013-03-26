# BoincStat  factory definition

FactoryGirl.define do
  sequence :g_boinc_id do |n|
    n+100
  end
  sequence :g_test_email do |n|
    "#{Faker::Name.first_name}.#{Faker::Name.last_name}.#{n}@test.com"
  end
  sequence :g_nereus_id do |n|
    n+10100
  end

  factory :general_stats_item do
    rank 0
    recent_avg_credit 0
    total_credit 0
    last_trophy_credit_value 0

    after(:create) {|general_stats_item|
      general_stats_item.boinc_stats_item = BoincStatsItem.where(:boinc_id => generate(:g_boinc_id)).first
      general_stats_item.nereus_stats_item = NereusStatsItem.where(:nereus_id => generate(:g_nereus_id)).first
    }
  end

  factory :profile do
    first_name {Faker::Name.first_name }
    second_name {Faker::Name.last_name }
    country { Faker::Address.country }

    after(:create) {|profile|
      profile.general_stats_item = FactoryGirl.create(:general_stats_item)
    }
  end

  factory :user do
    email { generate(:g_test_email) }
    password 'password'
    admin false

    after(:create) {|user|
       user.profile = FactoryGirl.create(:profile)
    }
  end

  factory :alliance do
    name { Faker::Company.name }
    ranking 0
    credit 0

    after(:create) {|alliance|
      user = FactoryGirl.create(:user)
      user.profile.join_alliance(alliance)
      alliance.leader = user.profile
      for i in 0..10
        user = FactoryGirl.create(:user)
        user.profile.join_alliance(alliance)
      end
    }

  end
end
