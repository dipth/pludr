FactoryBot.define do
  factory :user do
    username { Faker::Internet.username }
    name { Faker::Name.name }
    email_address { Faker::Internet.email }
    password { "password" }
    password_confirmation { "password" }
    admin { false }
  end
end
