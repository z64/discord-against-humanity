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
    end
  end
end
