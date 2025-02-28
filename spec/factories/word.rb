FactoryBot.define do
  factory :word do
    value { ('a'..'z').to_a.sample(rand(4..10)).join }
  end
end
