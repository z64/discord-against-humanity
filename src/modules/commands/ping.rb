module Bot
  module DiscordCommands
    # Responds with "Pong!".
    # This used to check if bot is alive
    module Ping
      extend Discordrb::Commands::CommandContainer
      command(:ping, help_available: false) do |event|
        break unless event.user.id == CONFIG.owner
        "`#{event.timestamp - Time.now}ms`"
      end
    end
  end
end
