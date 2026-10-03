FactoryBot.define do
  factory :camp do
    sequence(:name) { |n| "Camp #{n}" }
    password { "password" }

    trait :with_teams do
      transient do
        teams_count { 2 }
      end

      after(:create) do |camp, evaluator|
        create_list(:team, evaluator.teams_count, camps: [camp])
      end
    end

    trait :with_games do
      with_teams

      transient do
        games_count { 2 }
      end

      after(:create) do |camp, evaluator|
        camp.reload.teams.each do |team|
          create_list(:game, evaluator.games_count, camp: camp, team: team)
        end
      end
    end
  end
end
