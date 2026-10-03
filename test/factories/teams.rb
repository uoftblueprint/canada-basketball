FactoryBot.define do
  factory :team do
    sequence(:name) { |n| "Team #{n}" }

    trait :with_players do
      transient do
        players_count { 3 }
      end

      after(:create) do |team, evaluator|
        create_list(:player, evaluator.players_count, team: team)
      end
    end

    trait :with_camps do
      transient do
        camps_count { 2 }
      end

      after(:create) do |team, evaluator|
        create_list(:camp, evaluator.camps_count, teams: [team])
      end
    end

    trait :with_games do
      with_camps

      transient do
        games_count { 2 }
      end

      after(:create) do |team, evaluator|
        team.reload.camps.each do |camp|
          create_list(:game, evaluator.games_count, team: team, camp: camp)
        end
      end
    end
  end
end
