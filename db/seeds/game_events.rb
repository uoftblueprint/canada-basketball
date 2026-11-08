module Seeds
  class GameEvents
    class << self
      def run
        ActiveRecord::Base.connection.truncate_tables("game_events", "game_stat_lines")
        seed_game_events
      end

      private

      def seed_game_events
        puts "Seeding game events"

        Game.includes(team: :players).find_each do |game|
          players = game.team.players.to_a
          next if players.empty?

          seed_player_events(game, players)
          seed_team_event(game)
          seed_opponent_events(game)
        end
      end

      def seed_player_events(game, players)
        players.each do |player|
          game.game_events.create!(player: player, kind: :two_point_made)
          game.game_events.create!(player: player, kind: :three_point_missed)
          game.game_events.create!(player: player, kind: :defensive_rebound)
        end
      end

      def seed_team_event(game)
        game.game_events.create!(player: nil, is_opponent: false, kind: :turnover)
      end

      def seed_opponent_events(game)
        game.game_events.create!(player: nil, is_opponent: true, kind: :three_point_made)
        game.game_events.create!(player: nil, is_opponent: true, kind: :offensive_rebound)
      end
    end
  end
end
