FactoryBot.define do
  factory :user do
    username { Faker::Internet.username(separators: "-_", specifier: 3..30) }
    name { Faker::Name.name }
    email_address { Faker::Internet.email }
    password { "password" }
    password_confirmation { "password" }
    admin { false }
  end
end
