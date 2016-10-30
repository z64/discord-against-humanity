Sequel.migration do
  up do
    add_column :discord_nick, :players, String
  end

  down do
    drop_column :discord_nick, :players
  end
end
