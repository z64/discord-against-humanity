module Bot
  module Database
    # An expansion
    class Answer < Sequel::Model
      many_to_one :expansion

      # Log creation
      def after_create
        Discordrb::LOGGER.info("created answer #{inspect}")
      end
    end
  end
end
