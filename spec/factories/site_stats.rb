# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :site_stat do
    name "MyString"
    current_value 1
    previous_value 1
    change_time "2013-06-18 16:53:14"
  end
end
