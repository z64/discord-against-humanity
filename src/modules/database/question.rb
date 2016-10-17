module Bot
  module Database
    # An expansion
    class Question < Sequel::Model
      many_to_one :expansion

      # Log creation
      def after_create
        Discordrb::LOGGER.info("created question #{inspect}")
      end

      # Substitutes a set of answers
      # into a question's slots
      def substitute(answers)
        text.gsub(/_/) { "`#{answers.shift.text}`" }
      end
    end
  end
end
