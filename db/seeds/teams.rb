module Seeds
  class Teams
    class << self
      PlayerData = Data.define(:name)
      TeamData = Data.define(:name, :players)

      def run
        ActiveRecord::Base.connection.truncate_tables("teams", "players")
        seed_teams
      end

      private

      def seed_teams
        puts "Seeding teams and players"
        team_data.map do |team_datum|
          create_team(team_datum)
        end
      end

      def team_data
        [
          TeamData.new(
            "Team 1",
            [
              PlayerData.new(
                "Player 1"
              ),
              PlayerData.new(
                "Player 2"
              ),
              PlayerData.new(
                "Player 3"
              )
            ]
          ),
          TeamData.new(
            "Team 2",
            [
              PlayerData.new(
                "Player 4"
              ),
              PlayerData.new(
                "Player 5"
              ),
              PlayerData.new(
                "Player 6"
              )
            ]
          )
        ]
      end

      def create_team(team_datum)
        Team.create!(
          name: team_datum.name,
          players: team_datum.players.map { |player_datum| Player.new(name: player_datum.name) }
        )
      end
    end
  end
end
