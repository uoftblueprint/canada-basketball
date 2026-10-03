module Seeds
  class Camps
    class << self
      def run
        ActiveRecord::Base.connection.truncate_tables("camps", "camp_assignments")
        seed_camps
      end

      private

      def seed_camps
        puts "Seeding camps"
        create_camps_from_teams(teams)
      end

      # Create a camp with team 1, a camp with team 1 and 2, etc
      def create_camps_from_teams(teams)
        teams.each_with_index do |_, index|
          Camp.create!(
            name: "Camp #{index + 1}",
            password: "password",
            teams: teams[0, index + 1]
          )
        end
      end

      def teams = Team.all
    end
  end
end
