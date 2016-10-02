module Bot
  module DiscordCommands
    # Syncs expansions with db
    module Sync
      extend Discordrb::Commands::CommandContainer
      command(:sync,
              help_available: false,
              description: 'syncs card database',
              usage: "#{BOT.prefix}sync") do |_event|
        # wipe current db
        Database::Expansion.all.map(&:destroy)

        # load from dah-cards submodule
        Dir.glob('data/dah-cards/*.yaml').each do |f|
          data = YAML.load_file(f)
          expansion = Database::Expansion.find(name: data['expansion'])
          next unless expansion.nil?

          expansion = Database::Expansion.create(name: data['expansion'])
          expansion.update(authors: data['authors'].join(', ')) if data['authors']

          data['questions'].uniq.each do |c|
            answers = c.scan(/\_/).count.zero? ? 1 : c.scan(/\_/).count
            Database::Question.create(
              text: c,
              answers: answers,
              expansion: expansion
            )
          end

          data['answers'].uniq.each do |c|
            Database::Answer.create(
              text: c,
              expansion: expansion
            )
          end
        end
        'sync complete'
      end
    end
  end
end
