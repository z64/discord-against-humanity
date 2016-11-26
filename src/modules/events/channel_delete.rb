module Bot
  module DiscordEvents
    module ChannelDelete
      extend Discordrb::EventContainer
      channel_delete(type: 0) do |event|
        game = Database::Game.find text_channel_id: event.id
        next unless game
        begin
          game.end!
        rescue
          # Fail silently if we already deleted the channel
          # (Clean exit)
        end
      end
    end
  end
end
