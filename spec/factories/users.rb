FactoryBot.define do
  factory :user do
    username { Faker::Internet.username(separators: "-_", specifier: 3..30) }
    name { Faker::Name.name }
    email_address { Faker::Internet.email }
    password { "password" }
    password_confirmation { "password" }
    admin { false }

    trait :with_legacy_password_1 do
      # This is the password "qwerty42" salted with "CnCdCPxhui2YjO_OyuwS" and hashed with SHA512 and stretched 20 times.
      password_digest { "LEGACY.d48abbaa72fc69bb30659ee850dfa4646fa6d82b17cd979bf5353366bb2ca5895eb3f059f803a0c4e0c81fe702e0b2305d965a8e64bf400b59ec9a2dcb9fe2e5.CnCdCPxhui2YjO_OyuwS" }
    end

    trait :with_legacy_password_2 do
      # This is the password "qwerty43" salted with "CnCdCPxhui2YjO_OyuwS" and hashed with SHA512 and stretched 20 times.
      password_digest { "LEGACY.2dd7a7bb8c4b2a43ba1954a4a047c5a6459f8d7af2a5282e941f1548e02ab656b8e722276fa612d0c413cba1ed5e16c9ef9367a756b9aa0e10e7571c330f3a40.CnCdCPxhui2YjO_OyuwS" }
    end
  end
end
