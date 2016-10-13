module Bot
  module Database
    # A Player
    class Player < Sequel::Model
      many_to_one :game
      one_to_many :player_cards
      one_to_many :plays

      # Restock a players hand with unplayed cards
      def restock_hand!
        return if CONFG.hand_size == unplayed_cards.count
        (CONFIG.hand_size - unplayed_cards.count).times do
          add_player_card PlayerCard.create(answer: game.available_answers.sample)
        end
      end

      # Returns player cards that haven't been played yet
      def unplayed_cards
        player_cards.where(played: false)
      end

      # Check if the player owns an active
      # game they're associated with
      def game_owner?
        self == game.owner if game.winner.nil?
      end

      # Check if player is the czar
      # of the game they're associated with
      def czar?
        self == game.czar
      end
    end
  end
end
