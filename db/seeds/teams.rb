module Seeds
  class Teams
    class << self
      PlayerData = Data.define(:name)
      TeamData = Data.define(:name, :players)
      HOMETOWNS = [
        %w[ON Toronto], %w[QC Montreal], %w[BC Vancouver], %w[AB Calgary],
        %w[MB Winnipeg], %w[NS Halifax], %w[SK Saskatoon], ["NL", "St. John's"]
      ].freeze

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
            player = create_player(player_index, camp)
            camp.camp_registrations.create!(player: player, team: team)
          end

          team = camp.teams.create!(name: "Team 2")

          (4..6).map do |player_index|
            player = create_player(player_index, camp)
            camp.camp_registrations.create!(player: player, team: team)
          end
        end
      end

      def create_player(player_index, camp)
        province, hometown = HOMETOWNS[(player_index + camp.id) % HOMETOWNS.size]

        Player.create!(
          name: "Player #{player_index} (Camp #{camp.id})",
          birth_year: 2005 + (player_index % 5),
          height_cm: 170 + (player_index * 5),
          province: province,
          hometown: hometown
        )
      end

      def camps = Camp.all
    end
  end
end
