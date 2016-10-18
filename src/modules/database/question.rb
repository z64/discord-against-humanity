module Bot
  module Database
    # An expansion
    class Question < Sequel::Model
      many_to_one :expansion

      # Log creation
      def after_create
        Discordrb::LOGGER.info("created question #{inspect}")
      end

      # Format an answer to evade markdown
      def print
        text.gsub(/_/) { '\_\_\_' }
      end

      # Substitutes a set of answers
      # into a question's slots
      def substitute(answers)
        if text.scan(/_/).count.zero?
          "#{text} `#{answers.first.text}`"
        else
          text.gsub(/_/) { "`#{answers.shift.text}`" }
        end
      end
    end
  end
end
