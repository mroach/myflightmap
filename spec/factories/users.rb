FactoryGirl.define do
  factory :user do
    username { Faker::Internet.user_name }
    sequence(:email) { |n| Faker::Internet.safe_email("#{username}#{n}") }
    password { Faker::Internet.password(20) }
  end
end
