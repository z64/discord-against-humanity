module Bot
  module Database
    # A Game
    class Game < Sequel::Model
      many_to_one :owner,  class: '::Bot::Database::Player'
      many_to_one :winner, class: '::Bot::Database::Player'
      one_to_many :players
      one_to_many :rounds
      one_to_many :expansion_pools

      # Set up model before creation
      def before_create
        super
        self.timestamp ||= Time.now
      end

      # Returns the game owned by the associated
      # Discord ID
      def self.owner(id)
        all.find { |g| g.owner.discord_id == id }
      end

      # Clean up before destruction
      def before_destroy
        delete_channels
      end

      # Get a formatted name of the game
      def name
        "game_#{id}"
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

      # Starts a game
      def start!
        return if started
        next_round!
        update(started: true)
      end

      # Creates a new round and distrubtes player cards
      def next_round!
        czar = players.at(rounds.count % players.count)
        add_round Round.create(question: available_questions.sample, czar: czar)
        current_round.update_message!
        players.each do |p|
          p.restock_hand!
          p.update_nick!
          unless p.czar?
            p.dm_unplayed
          else
            p.announce_czar
          end
        end
      end

      # Returns the current round
      def current_round
        rounds.last
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

      # Returns the Expansions currently included in the game
      def expansions
        expansion_pools.collect(&:expansion)
      end

      # Returns a flattened dataset of questions available
      # in the current game's expansion pools
      def questions
        expansions.map(&:questions).flatten
      end

      # Returns questions that have been used in the game so far
      def questions_in_game
        rounds.collect(&:question)
      end

      # Returns quetsions that haven't been put into the game yet
      def available_questions
        questions - questions_in_game
      end

      # Returns a flattened dataset of answers available
      # in the current game's expansion pools
      def answers
        expansions.map(&:answers).flatten
      end

      # Returns answers that have been used in the game so far
      def answers_in_game
        players.collect(&:player_cards).flatten.map(&:answer)
      end

      # Returns answers that haven't been put into the game yet
      def available_answers
        answers - answers_in_game
      end
    end
  end
end
