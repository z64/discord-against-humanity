module Bot
  module DiscordEvents
    # Main interface for controlling game flow
    # by picking cards to play, or picking the
    # plays to win and advance to the next round.
    module Play
      extend Discordrb::EventContainer

      # Game logic hash that defines
      # gameplay flow / rules
      PLAY = {
        [:CZAR, :PENDING] => :IDLE,
        [:CZAR, :WAITING_RESPONSES] => :WAITING_RESPONSE,
        [:CZAR, :ENOUGH_RESPONSES] => :EXECUTE_PICK,
        [:CZAR, :COMPLETE] => :IDLE,
        [:CZAR, :INPUT_ERROR] => :INPUT_ERROR,

        [:PLAYER, :PENDING] => :IDLE,
        [:PLAYER, :WAITING_RESPONSES] => :EXECUTE_PLAY,
        [:PLAYER, :ENOUGH_RESPONSES] => :IDLE,
        [:PLAYER, :COMPLETE] => :IDLE,
        [:PLAYER, :INPUT_ERROR] => :INPUT_ERROR
      }.freeze

      # The syntax for a pick/play event trigger
      PLAY_REGEX = /pick+\s\d+$|play+\s\d+$/i

      message(content: PLAY_REGEX) do |event|
        # Find an active player
        player = Database::Player.find_active(event.user.id)

        # Default to idle verb
        verb = :IDLE

        unless player.nil?
          # Determine the player's identity
          identity = player.czar? ? :CZAR : :PLAYER

          # Get the player's cards
          cards = player.unplayed_cards

          # Get the active game
          game = player.game

          # Get the current round
          round = game.current_round

          # Parse input
          input = event.message.content.split(' ').last.to_i

          # Round responses
          responses = round.responses

          # Determine state
          state = :PENDING unless game.started
          state = :COMPLETE if game.winner

          state = round.enough_responses? ? :ENOUGH_RESPONSES : :WAITING_RESPONSES
          state = :ENOUGH_RESPONSES if player.enough_responses?

          state = :INPUT_ERROR if input <= 0
          case identity
          when :PLAYER
            state = :INPUT_ERROR if input > cards.count
          when :CZAR
            state = :INPUT_ERROR if input > responses.count && state == :ENOUGH_RESPONSES
          end

          # Derive game verb
          verb = PLAY[[identity, state]]

          # Perform action
          case verb
          when :WAITING_RESPONSE
            event.respond '❎ Still waiting for player responses..'
            next

          when :EXECUTE_PICK
            response = responses[input - 1]
            round.update winner: response.first.player
            round.update_message!
            response.first.player.update_score!
            game.text_channel.send_message(
              "**#{round.question.substitute(response.map(&:answer))}**\n"\
              "#{response.first.player.discord_user.mention} has won this round!🥇",
              game.use_tts,
              game.generate_embed
            )

          when :EXECUTE_PLAY
            if event.channel.pm?
              card = cards[input - 1]
              if round.plays.collect(&:player_card).include? card
                event.respond '❎ You\'ve already picked this card.'
                next
              else
                card.play!
                if player.remaining_responses.zero?
                  event.respond '☑️'
                else
                  event.respond "☑️ (pick #{player.remaining_responses} more)"
                end
              end
            end

          when :INPUT_ERROR
            event.respond '❎ You didn\'t specify a valid card number!'
            next

          when :IDLE
            next
          end

          if round.enough_responses?
            round.plays.each { |p| p.player_card.update played: true }
            round.update_message!
            game.text_channel.send_message(
              "#{round.czar.discord_user.mention}, all cards are in!\n"\
              'Pick a winning card with `pick [number]`'
            )
          end

          winner = Database::Game[game.id].winner
          if winner
            game.update winner: winner
            game.text_channel.send_message(
              "🎉 **@here, #{winner.discord_user.mention} has won the game!** 🎉\n\n"\
              "#{game.owner.discord_user.mention} When you're done,"\
              ' run `dah.end` to close the game and this channel.'
            )
          elsif verb == :EXECUTE_PICK
            sleep 10
            game.next_round!
          end
        end
      end
    end
  end
end
