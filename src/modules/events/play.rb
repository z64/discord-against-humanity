module Bot
  module DiscordEvents
    # Chat hooks for gameplay
    module Play
      extend Discordrb::EventContainer

      # Picks a winning card
      message(start_with: /pick/i) do |event|
        number = event.message.content.split(' ').last.to_i - 1
        player = Database::Player.find_active(event.user.id)
        unless player.nil? || !player.game.started
          if player.czar?
            unless player.game.current_round.enough_responses?
              event.respond('Still waiting for other players to pick cards.. :eyes:')
            else
              response = player.game.current_round.responses.at(number)
              unless response.nil?
                player.game.current_round.update(winner: response.first.player)
                player.game.current_round.update_message!
                response.first.player.update_score!
              else
                event.respond(':negative_squared_cross_mark:')
              end
            end
          else
            if event.channel.pm?
              card = player.unplayed_cards.at(number)
              unless card.nil? || player.enough_responses? || player.game.current_round.enough_responses?
                card.play!
                event.respond(':ballot_box_with_check:')
                if player.game.current_round.enough_responses?
                  player.game.current_round.update_message!
                  player.game.text_channel.send_message(
                    "#{player.game.current_round.czar.discord_user.mention}, all cards are in!\n"\
                    "Pick a winning card with `pick [number]`!"
                  )
                end
              else
                event.respond(':negative_squared_cross_mark:')
              end
            end
          end
        end
      end
    end
  end
end
