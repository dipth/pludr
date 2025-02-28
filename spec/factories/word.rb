FactoryBot.define do
  factory :word do
    value { Faker::Lorem.word }
  end
end
