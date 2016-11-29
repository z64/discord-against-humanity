module Bot
  module DiscordCommands
    # Urban Dictionary
    module Urban
      extend Discordrb::Commands::CommandContainer

      class UrbanDictionary::Definition
        def long?(text)
          return true if text.length > 1024
        end
        def shorten(text,extra='')
          maxlength = 1023 - extra.length
          return text[0..maxlength].strip + extra
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
        word.example.gsub!('*','')

        event.channel.send_embed do |e|
          e.add_field name: 'Definition',
            value: word.long?(word.text) ? word.shorten(word.text,url) : word.text, inline: false
          e.add_field name: 'Example',
            value: word.long?(word.example) ? word.shorten(word.example,'...') : word.example, inline: false if word.example
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
