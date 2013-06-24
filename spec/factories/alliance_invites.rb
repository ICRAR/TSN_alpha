# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :alliance_invite do
    invited_by 1
    alliance_id 1
    token "MyString"
    used false
    email "MyString"
    invited_on "2013-06-24 10:06:07"
    redeemed_on "2013-06-24 10:06:07"
  end
end
