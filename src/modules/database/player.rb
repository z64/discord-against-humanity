module Bot
  module Database
    # A Player
    class Player < Sequel::Model
      many_to_one :game
      one_to_many :player_cards
      one_to_many :plays

      # Check if the player owns an active
      # game they're associated with
      def game_owner?
        self == game.owner if game.winner.nil
      end

      # Check if player is the czar
      # of the game they're associated with
      def czar?
        self == game.czar
      end
    end
  end
end
