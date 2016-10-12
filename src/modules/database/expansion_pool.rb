module Bot
  module Database
    # An expansion pool for a Game
    class ExpansionPool < Sequel::Model
      many_to_one :expansion
      many_to_one :game
    end
  end
end
