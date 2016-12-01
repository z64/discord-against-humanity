module Bot
  module DiscordCommands
    # Urban Dictionary
    module Urban
      extend Discordrb::Commands::CommandContainer

      class UrbanDictionary::Definition
        def long_text?
          text.length > 1024
        end

        def long_example?
          example.length > 1024
        end
      end

      command([:ud, :urban],
              description: 'look up a word on Urban Dictionary',
              usage: "#{BOT.prefix}urban (word)") do |event, *term|
        term = term.join(' ')
        word   = UrbanDictionary.random.first if term.empty?
        word ||= UrbanDictionary.define(term).first
        next "Couldn't find anything for `#{term}` 😕" unless word
        url = "... [(Read More)](#{word.url})"
        word.example.delete!('*')

        event.channel.send_embed do |e|
          e.add_field name: 'Definition', value: word.long_text? ? truncate(word.text, url) : word.text, inline: false
          if word.example
            e.add_field name: 'Example', value: word.long_example? ? truncate(word.example, '...') : word.example, inline: false
          end
          e.add_field name: "\u200B", value: "⬆️ `#{word.thumbs_up}` ⬇️ `#{word.thumbs_down}`", inline: false
          e.author = {
            icon_url: 'http://www.dimensionalbranding.com/userfiles/urban_dictionary.jpg',
            name: word.word,
            url: word.url
          }
          e.footer = { text: "Author: #{word.author}" }
          e.color = 5800090
        end
      end

      module_function

      def truncate(text, append = '')
        maxlength = 1024 - append.length
        text[0...maxlength].strip + append
      end
    end
  end
end
