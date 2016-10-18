module Bot
  module Database
    # A play in a round
    class Play < Sequel::Model
      many_to_one :round
      many_to_one :player_card
    end
  end
end
