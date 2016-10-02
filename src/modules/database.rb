# Gems
require 'sequel'

module Bot
  # SQL Database
  module Database
    # Load migrations
    Sequel.extension :migration

    # Connect to database
    DB = Sequel.connect('sqlite://data/dah.db')

    # Run migrations
    Sequel::Migrator.run(DB, 'src/modules/database/migrations')

    # Load models
    Dir['src/modules/database/*.rb'].each { |mod| load mod }

    # Initialize database (maybe)
    def self.init!
      # sync with data/dah-cards
    end
  end
end
