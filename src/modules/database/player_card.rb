module Bot
  module Database
    # A player card
    class PlayerCard < Sequel::Model
      many_to_one :player
      many_to_one :answer
    end
  end
end
