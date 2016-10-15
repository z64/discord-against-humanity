module Bot
  module DiscordCommands
    # Commands to manage game creation and flow
    module Game
      extend Discordrb::Commands::CommandContainer
      # Creates a new game
      command(:new) do |event|
        if Database::Game.owner(event.user.id)
          'You can only host one game at a time. '\
          'Use `dah.end` to end an active game that you host.'
        else
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
        end
      end

      # Invites users to game
      command(:invite) do |event|
        if event.message.mentions.empty?
          event << 'Mention a user to invite!'
          return
        end

        game = Database::Game.owner(event.user.id)
        unless game.nil?
          event.message.mentions.each do |u|
            if game.players.any? { |p| p.discord_id == u.id }
              event << "`#{u.distinct}` is already part of your game!"
            else
              game.add_player Database::Player.create(discord_id: u.id, discord_name: u.distinct)

              # TODO: Create Permissions template for this
              permissions = Discordrb::Permissions.new
              permissions.can_read_messages = true
              permissions.can_connect       = true
              [game.text_channel, game.voice_channel].each do |c|
                c.define_overwrite(u, permissions, nil)
              end
              event << "Added #{u.distinct} to your game!"
            end
          end
          return
        end
        'You aren\'t hosting any active games.'
      end

      # Adds an expansion to the game
      command(:add_expansion, min_args: 1) do |event, *names|
        game = Database::Game.owner(event.user.id)
        if game.nil?
          event << 'You aren\'t hosting any active games.'
          return
        end

        names = names.join(' ').split(',').map(&:strip)
        names.each do |name|
          expansion = Database::Expansion.find(Sequel.ilike(:name, name))
          unless expansion.nil?
            if game.expansion_pools.find { |e| e.expansion == expansion }
              event << "Expansion `#{expansion.name}` is already in your game."
            else
              game.add_expansion_pool(Database::ExpansionPool.create(expansion: expansion))
              event << "Added expansion: `#{expansion.name}`"
            end
          else
            event << "Could not find expansion: `#{name}`"
          end
        end
        nil
      end

      # Removes an expansion from the game
      command(:remove_expansion, min_args: 1) do |event, *names|
        game = Database::Game.owner(event.user.id)
        if game.nil?
          event << 'You aren\'t hosting any active games.'
          return
        end

        names = names.join(' ').split(',').map(&:strip)
        names.each do |name|
          expansion = Database::Expansion.find(Sequel.ilike(:name, name))
          pool = game.expansion_pools.find { |e| e.expansion == expansion }
          if pool
            event << "Removed expansion: `#{expansion.name}`"
            pool.destroy
          else
            event << "Expansion not found: `#{expansion.name}`"
          end
        end
        nil
      end

      # Starts a game
      command(:start) do |event|
        game = Database::Game.owner(event.user.id)
        unless game.nil?
          if game.players.count >= CONFIG.min_players
            game.start!
            event.bot.send_message(game.text_channel, "**@everyone, `dah game ##{game.id}` has started!**")
            game.current_round.update_message!
          else
            event << "You must have at least `#{CONFIG.min_players}` "\
                     'players to start a game!'
          end
          return
        end
        'You aren\'t hosting any active games.'
      end

      # Ends a game
      command(:end) do |event|
        game = Database::Game.owner(event.user.id)
        if game.nil?
          'You aren\'t hosting any active games.'
        else
          game.end!
          nil
        end
      end
    end
  end
end
