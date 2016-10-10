module Bot
  module Database
    # A Game
    class Game < Sequel::Model
      many_to_one :owner,  class: '::Bot::Database::Player'
      many_to_one :czar,   class: '::Bot::Database::Player'
      many_to_one :winner, class: '::Bot::Database::Player'
      one_to_many :players
      one_to_many :rounds
    end
  end
end
