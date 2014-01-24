# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sub_shout_box, :class => 'Sub::ShoutBox' do
    id 1
    msg "MyString"
  end
end
