module Bot
  module Database
    # A Game
    class Game < Sequel::Model
      many_to_one :owner,  class: '::Bot::Database::Player'
      many_to_one :czar,   class: '::Bot::Database::Player'
      many_to_one :winner, class: '::Bot::Database::Player'
      one_to_many :players
      one_to_many :rounds

      # Clean up before destruction
      def before_destroy
        text_channel.delete
        voice_channel.delete
      end

      # Fetch channel from bot cache
      def text_channel
        BOT.channel(text_channel_id)
      end

      # Fetch channel from bot cache
      def voice_channel
        BOT.channel(voice_channel_id)
      end
    end
  end
end
