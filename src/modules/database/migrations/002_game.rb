Sequel.migration do
  up do
    create_table(:games) do
      primary_key :id
      DateTime :timestamp
      Integer :text_channel_id, unique: true
      Integer :voice_channel_id, unique: true
      foreign_key :owner_id, :players, on_delete: :set_null
      foreign_key :winner_id, :players, on_delete: :set_null
      TrueClass :started, default: false
      Integer :max_points
      TrueClass :use_tts, default: false
    end

    create_table(:players) do
      primary_key :id
      Integer :discord_id
      String :discord_name
      Integer :score, default: 0
      foreign_key :game_id, :games, on_delete: :cascade
    end

    create_table(:rounds) do
      primary_key :id
      foreign_key :game_id, :games, on_delete: :cascade
      foreign_key :question_id, :questions, on_delete: :cascade
      foreign_key :czar_id, :players, on_delete: :set_null
      foreign_key :winner_id, :players, on_delete: :cascade
    end

    create_table(:player_cards) do
      primary_key :id
      foreign_key :player_id, :players, on_delete: :cascade
      foreign_key :answer_id, :answers, on_delete: :cascade
      TrueClass :played, default: false
    end

    create_table(:plays) do
      primary_key :id
      foreign_key :player_card_id, :player_cards, on_delete: :cascade
      foreign_key :round_id, :rounds, on_delete: :cascade
    end
  end

  down do
    drop_table(:games)
    drop_table(:players)
    drop_table(:rounds)
    drop_table(:player_cards)
    drop_table(:plays)
  end
end
