FactoryBot.define do
  factory :team do
    sequence(:name) { |n| "Team #{n}" }
    camp

    trait :with_players do
      transient do
        players_count { 3 }
      end

      after(:create) do |team, evaluator|
        create_list(:player, evaluator.players_count).each do |player|
          create(:camp_registration, camp: team.camp, player: player, team: team)
        end
      end
    end

    trait :with_games do
      transient do
        games_count { 2 }
      end

      after(:create) do |team, evaluator|
        create_list(:game, evaluator.games_count, team: team, camp: team.camp)
      end
    end
  end
end
