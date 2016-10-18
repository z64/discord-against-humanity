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
              event.respond(':ballot_box_with_check:')
            end
          else
            if event.channel.pm?
              card = player.unplayed_cards.at(number)
              unless card.nil? || player.enough_responses?
                player.game.current_round.add_play(player_card: card)
                player.game.current_round.update_message!
                event.respond(':ballot_box_with_check:')
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
