module Bot
  module Database
    # A Game
    class Game < Sequel::Model
      many_to_one :owner,  class: '::Bot::Database::Player'
      many_to_one :czar,   class: '::Bot::Database::Player'
      many_to_one :winner, class: '::Bot::Database::Player'
      one_to_many :players
      one_to_many :rounds

      # Returns the game owned by the associated
      # Discord ID
      def self.owner(id)
        all.find { |g| g.owner.discord_id == id }
      end

      # Clean up before destruction
      def before_destroy
        delete_channels
      end

      # Fetch channel from bot cache
      def text_channel
        BOT.channel(text_channel_id)
      end

      # Fetch channel from bot cache
      def voice_channel
        BOT.channel(voice_channel_id)
      end

      # Deletes Discord channels for the game
      def delete_channels
        text_channel.delete
        voice_channel.delete
      end

      # End a game. Destroys the game
      # if it has no decided winner, otherwise
      # keep the Game for history and just clean
      # up the channels.
      def end!
        if winner.nil?
          destroy
        else
          delete_channels
        end
      end
    end
  end
end
