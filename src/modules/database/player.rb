module Bot
  module Database
    # A Player
    class Player < Sequel::Model
      many_to_one :game
      one_to_many :player_cards
      one_to_many :plays

      # Restock a players hand with unplayed cards
      def restock_hand!
        return if Bot::CONFIG.hand_size == unplayed_cards.count
        (Bot::CONFIG.hand_size - unplayed_cards.count).times do
          add_player_card PlayerCard.create(answer: game.available_answers.sample)
        end
      end

      # Updates a player's points
      def update_score!
        update(score: game.rounds.count { |g| g.winner == self })
      end

      # Returns whether the player has made
      # enough responses to satisfy the current round.
      def enough_responses?
        game.current_round.response(self).count >= game.current_round.question.answers
      end

      # Fetches Discord user from bot cache
      def discord_user
        BOT.user(discord_id)
      end

      # Direct message the player their unplayed cards
      def dm_unplayed
        question = game.current_round.question.print
        m = []
        m << "`[#{game.name}]` | "\
             "Round ##{game.rounds.count} Question: **#{question}**"
        m << "**Your Cards:**"
        unplayed_cards.each_with_index do |c, i|
          m << "**#{i+1}.** ▫ #{c.answer.text}"
        end
        m << 'Respond with `pick [number]` to pick a card for this round.'
        discord_user.pm(m.join("\n"))
      end

      # Tells the player that they are the czar
      def announce_czar
        return unless czar?
        game.text_channel.send_message("**#{discord_user.mention} is the Czar this round..**")
      end

      # Returns player cards that haven't been played yet
      def unplayed_cards
        player_cards.select { |c| c.unplayed? }
      end

      # Returns player cards that have been played
      def played_cards
        player_cards.select { |c| c.played? }
      end

      # Plays a player's card to the current Round
      def play_card(number)
        unplayed_cards[number].play!
      end

      # Check if the player owns an active
      # game they're associated with
      def game_owner?
        self == game.owner if game.winner.nil?
      end

      # Check if player is the czar
      # of the game they're associated with
      def czar?
        self == game.current_round.czar
      end

      # Returns if the Player's game is active
      def active?
        game.winner.nil?
      end

      # Finds an active player by ID
      def self.find_active(id)
        where(discord_id: id).find { |p| p.active? }
      end
    end
  end
end
