module Bot
  module DiscordCommands
    # Gives you a random short Answer as a nick.
    module Nick
      extend Discordrb::Commands::CommandContainer
      command(:nick,
              description: 'Gives you a random nickname!',
              usage: "#{BOT.prefix}nick") do |event|
        nick = Database::Answer.all
                               .select { |p| p.text.length < 16 }
                               .sample
                               .text
                               .gsub(/\.|!|\?/,'')
        begin
          event.user.nick = nick
          nil
        rescue
        end
      end
    end
  end
end
