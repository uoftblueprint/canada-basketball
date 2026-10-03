Rails.root.glob("db/seeds/**/*.rb").each { |file| require file }

return unless Rails.env.development?

Seeds::Admins.run
Seeds::Teams.run
Seeds::Camps.run
Seeds::Games.run
