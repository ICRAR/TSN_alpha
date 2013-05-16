# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :alliance_member, :class => 'AllianceMembers' do
    join_date "2013-05-10 10:47:03"
    leave_date "2013-05-10 10:47:03"
    start_credit 1
    leave_credit 1
  end
end
