module Bot
  module DiscordCommands
    # Posts a URL to invite the bot to another server.
    module Invite
      extend Discordrb::Commands::CommandContainer
      command(:invite_url, description: 'posts a URL to invite the bot to your server') { CONFIG.invite_url }
    end
  end
end
