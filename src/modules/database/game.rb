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

      # Returns the collection of active games
      def self.active
        where(winner_id: nil).all
      end

      # Returns the active game owned
      # by the associated Discord ID
      def self.owner(id)
        all.find { |g| g.owner.discord_id == id && g.winner.nil? }
      end

      # Clean up before destruction
      def before_destroy
        delete_channels
      end

      # Get a formatted name of the game
      def name
        "game_#{id}"
      end

      # Fetch server from bot cache
      def server
        BOT.server(server_id)
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
        text_channel.delete if text_channel
        voice_channel.delete if voice_channel
      rescue
        # Silently fail if we can't delete channels
        # for some reason (we lost perms somehow)
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
          if p.czar?
            p.announce_czar
          else
            p.dm_unplayed
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
        players.map(&:reset_nick!)
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

      # Returns whether we have enough questions to satisfy the number of
      # points desired for the game
      def enough_questions?
        questions.count >= max_points
      end

      # Returns we have enough answers (probably) to play the game without
      # running out of cards
      def enough_answers?
        return false if questions.empty?
        answers.count > questions.collect(&:answers).max * players.count * CONFIG.hand_size + max_points
      end

      # Returns whether we have enough cards (questions & answers) to
      # run a full game
      def enough_cards?
        enough_questions? && enough_answers?
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

      # Generates an embedded scoreboard
      def generate_embed
        embed = Discordrb::Webhooks::Embed.new
        embed.title = 'Scores'
        embed.color = 44783
        ladder = (1..players.count).to_a.join "\n"
        pl = Player.where(game: self).all.sort_by(&:score).reverse
        embed.add_field name: '#', value: ladder, inline: true
        embed.add_field name: 'Name', value: pl.collect(&:discord_name).join("\n"), inline: true
        embed.add_field name: 'Score', value: pl.collect(&:score).join("\n"), inline: true
        embed
      end
    end
  end
end
