module Bot
  module Database
    # A game Round
    class Round < Sequel::Model
      many_to_one :game
      one_to_many :plays
      many_to_one :play
    end
  end
end
