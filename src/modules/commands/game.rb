module Bot
  module DiscordCommands
    # Commands to manage game creation and flow
    module Game
      extend Discordrb::Commands::CommandContainer
      # Creates a new game
      command(:new) do |event|
      end

      # Invites users to game
      command(:invite) do |event|
      end

      # Starts a game
      command(:start) do |event|
      end

      # Ends a game
      command(:end) do |event|
      end
    end
  end
end
