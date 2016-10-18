module Bot
  module Database
    # A player card
    class PlayerCard < Sequel::Model
      many_to_one :player
      many_to_one :answer
      one_to_one  :play

      def play!
        Play.create(
          player_card: self,
          round: player.game.current_round
        )
      end

      # If the card hasn't been played
      def unplayed?
        !played
      end

      # If the card has been played
      def played?
        played
      end
    end
  end
end
