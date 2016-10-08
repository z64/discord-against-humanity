module Bot
  module Database
    # A Game
    class Game < Sequel::Model
      many_to_one :owner
      many_to_one :czar
      many_to_one :winner
      one_to_many :players
      one_to_many :rounds
    end
  end
end
