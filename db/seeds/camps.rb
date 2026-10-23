module Seeds
  class Camps
    class << self
      def run
        ActiveRecord::Base.connection.truncate_tables("camps")
        seed_camps
      end

      private

      def seed_camps
        puts "Seeding camps"
        create_camps
      end

      # Create a camp with team 1, a camp with team 1 and 2, etc
      def create_camps
        3.times do |index|
          Camp.create!(
            name: "Camp #{index + 1}",
            password: "password",
            description: "Description"
          )
        end
      end
    end
  end
end
