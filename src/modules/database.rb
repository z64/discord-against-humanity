require 'nobrainer'

NoBrainer.configure do |config|
  config.app_name = 'dah'
end

module Bot
  module Database
    # Lazily load database files
    Dir['src/modules/database/*.rb'].each { |mod| load mod }

    NoBrainer.sync_indexes
  end
end
