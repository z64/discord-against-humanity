module Bot
  module DiscordCommands
    # Commands to manage game creation and flow
    module Game
      extend Discordrb::Commands::CommandContainer
      # Creates a new game
      command(:new) do |event|
        unless Database::Player.where(discord_id: event.user.id)
                               .any?(&:game_owner?)
          # Create channels
          game_id = Database::Game.count + 1
          channels = {
            text: event.server.create_channel("game_#{game_id}", 0),
            voice: event.server.create_channel("game_#{game_id}", 2)
          }

          permissions = Discordrb::Permissions.new
          permissions.can_read_messages = true
          permissions.can_connect       = true

          channels.each do |_, c|
            c.define_overwrite(event.user, permissions, nil)
            c.define_overwrite(event.server.roles.first, nil, permissions)
          end

          # Create game
          game = Database::Game.create(
            text_channel_id:  channels[:text].id,
            voice_channel_id: channels[:voice].id,
            max_points: CONFIG.max_points
          )

          # Create player
          owner = Database::Player.create(
            discord_id: event.user.id,
            discord_name: event.user.distinct,
            game: game
          )

          # Assign game owner
          game.owner = owner
          game.save

          "**Created game: #{channels[:text].mention}**"
        else
          'You can only own one game at a time. '\
          'Use `dah.end` to end an active game that you own.'
        end
      end

      # Invites users to game
      command(:invite) do |event|
      end

      # Starts a game
      command(:start) do |event|
      end

      # Ends a game
      command(:end) do |event|
      end
    end
  end
end
