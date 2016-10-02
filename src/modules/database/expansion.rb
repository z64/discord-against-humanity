module Bot
  module Database
    # An expansion
    class Expansion < Sequel::Model
      one_to_many :questions
      one_to_many :answers

      # Log creation
      def after_create
        Discordrb::LOGGER.info("created expansion #{inspect}")
      end

      # returns the total number of cards
      # of the expansion
      #
      # @return [Integer] the number of cards
      def cards
        questions.count + answers.count
      end
    end
  end
end
