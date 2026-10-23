module Seeds
  class Teams
    class << self
      PlayerData = Data.define(:name)
      TeamData = Data.define(:name, :players)

      def run
        ActiveRecord::Base.connection.truncate_tables("teams", "players", "camp_registrations")
        seed_teams
      end

      private

      def seed_teams
        puts "Seeding teams, players, and registrations"
        create_team_from_camps(camps)
      end

      def create_team_from_camps(camps)
        camps.each do |camp|
          team = camp.teams.create!(name: "Team 1")

          (1..3).map do |player_index|
            player = Player.create!(name: "Player #{player_index} (Camp #{camp.id})")
            camp.camp_registrations.create!(player: player, team: team)
          end

          team = camp.teams.create!(name: "Team 2")

          (4..6).map do |player_index|
            player = Player.create!(name: "Player #{player_index} (Camp #{camp.id})")
            camp.camp_registrations.create!(player: player, team: team)
          end
        end
      end

      def camps = Camp.all
    end
  end
end
