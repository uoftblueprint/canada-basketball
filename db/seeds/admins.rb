module Seeds
  class Admins
    class << self
      def run
        ActiveRecord::Base.connection.truncate_tables("admins")
        seed_admins
      end

      private

      def seed_admins
        puts "Seeding admins"
        Admin.create!(email: "admin@test.com", name: "Test", password: "password")
      end
    end
  end
end
