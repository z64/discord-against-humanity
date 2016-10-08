module Bot
  module DiscordEvents
    # Chat hooks for gameplay
    module Play
      extend Discordrb::EventContainer

      # Plays a card
      message(starts_with: /play/i) do |event|
      end

      # Picks a winning card
      message(starts_with: /pick/i) do |event|
      end
    end
  end
end
