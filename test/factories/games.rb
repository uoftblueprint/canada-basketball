FactoryBot.define do
  factory :game do
    sequence(:name) { |n| "Game #{n}" }
    team
    camp { team.camp }
    opponent_name { "Opponent" }
    active { true }

    trait :inactive do
      active { false }
    end
  end
end
