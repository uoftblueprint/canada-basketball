module Seeds
  class Teams
    class << self
      PlayerStruct = Struct.new(:name)
      TeamStruct = Struct.new(:name, :players)

      def run
        ActiveRecord::Base.connection.truncate_tables("teams", "players")
        seed_teams
      end

      private

      def seed_teams
        puts "Seeding teams and players"
        team_data.map do |team_struct|
          create_team(team_struct)
        end
      end

      def team_data
        [
          TeamStruct.new(
            "Team 1",
            [
              PlayerStruct.new(
                "Player 1"
              ),
              PlayerStruct.new(
                "Player 2"
              ),
              PlayerStruct.new(
                "Player 3"
              )
            ]
          ),
          TeamStruct.new(
            "Team 2",
            [
              PlayerStruct.new(
                "Player 4"
              ),
              PlayerStruct.new(
                "Player 5"
              ),
              PlayerStruct.new(
                "Player 6"
              )
            ]
          )
        ]
      end

      def create_team(team_struct)
        Team.create!(
          name: team_struct.name,
          players: team_struct.players.map { |player_struct| Player.new(name: player_struct.name) }
        )
      end
    end
  end
end
