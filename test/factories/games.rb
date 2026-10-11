FactoryBot.define do
  factory :game do
    sequence(:name) { |n| "Game #{n}" }
    camp
    team
    opponent_name { "Opponent" }
    active { true }

    trait :inactive do
      active { false }
    end

    after(:build) do |game|
      game.camp.teams << game.team unless game.camp.teams.include?(game.team)
    end
  end
end
