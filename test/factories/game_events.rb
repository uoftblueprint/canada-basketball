FactoryBot.define do
  factory :game_event do
    game
    is_opponent { false }
    kind { "two_point_made" }

    # defaults to a player on the game's team
    player do
      create(:player).tap do |player|
        create(:camp_registration, camp: game.camp, player: player, team: game.team)
      end
    end

    trait :opponent do
      is_opponent { true }
      player { nil }
    end

    trait :team do
      is_opponent { false }
      player { nil }
    end
  end
end
