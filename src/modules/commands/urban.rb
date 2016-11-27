module Bot
  module DiscordCommands
    # Urban Dictionary
    module Urban
      extend Discordrb::Commands::CommandContainer

      class UrbanDictionary::Definition
        def long?
          [text.length, example.length].any? { |e| e > 1024 }
        end
      end

      command([:ud, :urban],
              description: 'look up a word on Urban Dictionary',
              usage: "#{BOT.prefix}urban (word)") do |event, *term|
        term = term.join(' ')
        word   = UrbanDictionary.random.first if term.empty?
        word ||= UrbanDictionary.define(term).first
        next "Couldn't find anything for `#{term}` 😕" unless word

        event.channel.send_embed do |e|
          e.description = '**Too long to display! Visit the URL by clicking above.**' if word.long?
          e.add_field name: 'Definition', value: word.text, inline: false unless word.long?
          e.add_field name: 'Example', value: "*#{word.example}*", inline: false if word.example unless word.long?
          e.add_field name: "\u200B", value: "⬆️ `#{word.thumbs_up}` ⬇️ `#{word.thumbs_down}`", inline: false
          e.author = {
            icon_url: 'http://www.dimensionalbranding.com/userfiles/urban_dictionary.jpg',
            name: word.word,
            url: word.url
          }
          e.footer = { text: "Author: #{word.author}"}
          e.color = 5800090
        end
      end
    end
  end
end
