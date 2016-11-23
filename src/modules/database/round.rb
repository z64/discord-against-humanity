module Bot
  module Database
    # A game Round
    class Round < Sequel::Model
      many_to_one :game
      one_to_many :plays
      many_to_one :czar, class: '::Bot::Database::Player'
      many_to_one :winner, class: '::Bot::Database::Player'
      many_to_one :question

      # Fetch round message from cache
      def message
        game.text_channel.message(message_id)
      end

      # Updates a round message, or posts one of it doesn't exist.
      def update_message!
        if winner.nil?
          m = game.text_channel.send_message(generate_message)
          update(message_id: m.id)
          # m.pin
        else
          message.edit(generate_message)
        end
      end

      # Groups a player's plays together into a response
      def response(player)
        plays.select { |p| p.player_card.player == player }
             .map { |p| p.player_card }
      end

      # Returns an object of current responses.
      def responses
        plays.collect { |p| p.player_card.player }
             .uniq
             .map { |p| response(p) }
      end

      # Determines if we have enough responses to advance the round
      def enough_responses?
        game.players.map(&:enough_responses?).count(true) == game.players.count - 1
      end

      # Generate a Round message. This will display a numbered
      # list of each play currently allocated to the round,
      # and if the round has a winning play, will reveal who submitted
      # each play.
      def generate_message
        m = []
        m << "`[#{game.name}]` | Round ##{game.rounds.count} Question: "\
             "**#{question.print}**"

        if question.answers > 1
          m << "Players, pick #{question.answers} cards."
        else
          m << "Players, pick #{question.answers} card."
        end

        unless plays.empty?
          m << "\n**Responses:**"
          responses.each_with_index do |rs, i|
            text = rs.map { |r| "`#{r.answer.text}`" }.join(', ')
            if winner.nil?
              m << "**#{i + 1}.** ▫ #{text}"
            else
              m << "**#{i + 1}.** ▫ #{text} (`#{rs.first.player.discord_name}`)"
            end
          end
        end
        m.join("\n")
      end
    end
  end
end
