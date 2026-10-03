FactoryBot.define do
  factory :game do
    sequence(:name) { |n| "Game #{n}" }
    camp
    team
    opponent_name { "Opponent" }

    after(:build) do |game|
      game.camp.teams << game.team unless game.camp.teams.include?(game.team)
    end
  end
end
