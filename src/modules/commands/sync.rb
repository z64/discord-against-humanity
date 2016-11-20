module Bot
  module DiscordCommands
    # Syncs expansions with db
    module Sync
      extend Discordrb::Commands::CommandContainer
      command([:sync,:hack_ur_stuff],
              help_available: false,
              description: 'syncs card database',
              usage: "#{BOT.prefix}sync") do |event|
        event.respond 'syncronizing cards, this may take a moment..'

        # load from dah-cards submodule
        Dir.glob('data/dah-cards/*.yaml').each do |f|
          data = YAML.load_file(f)

          # find existing expansion, otherwise create a new one
          expansion = Database::Expansion.find(name: data['expansion'])
          if expansion.nil?
            expansion = Database::Expansion.create(name: data['expansion'])
            if data['authors']
              expansion.update(authors: data['authors'].join(', '))
            else
              expansion.update(authors: 'cah')
            end
          end

          # wipe existing cards
          expansion.questions.map(&:destroy) unless expansion.questions.count.zero?
          expansion.answers.map(&:destroy) unless expansion.answers.count.zero?

          # restock questions
          data['questions'].uniq.each do |c|
            answers = c.scan(/\_/).count.zero? ? 1 : c.scan(/\_/).count
            Database::Question.create(
              text: c,
              answers: answers,
              expansion: expansion
            )
          end

          # restock answers
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
