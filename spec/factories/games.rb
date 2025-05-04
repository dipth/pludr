FactoryBot.define do
  factory :game do
    letters { Game::LETTERS.keys.sample(25).join }

    trait :building do
      workflow_state { :building }
    end

    trait :ready do
      building
      workflow_state { :ready }
      letters { Game::LETTERS.keys.sample(25).join }
    end

    trait :started do
      ready
      workflow_state { :started }
      started_at { Time.current }
    end

    trait :ended do
      started
      workflow_state { :ended }
      ended_at { Time.current }
    end

    trait :canceled do
      workflow_state { :canceled }
    end

    trait :failed do
      workflow_state { :failed }
    end
  end
end
