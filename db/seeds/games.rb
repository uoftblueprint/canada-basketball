module Seeds
  class Games
    class << self
      def run
        ActiveRecord::Base.connection.truncate_tables("games")
        seed_games
      end

      private

      def seed_games
        puts "Seeding games"

        camps.each do |camp|
          team = camp.teams.first
          create_game(camp, team) unless team.nil?
        end
      end

      def create_game(camp, team)
        Game.create!(
          name: "Game 1",
          opponent_name: "Opponent",
          team: team,
          camp: camp
        )
      end

      def camps = Camp.includes(:teams)
    end
  end
end
