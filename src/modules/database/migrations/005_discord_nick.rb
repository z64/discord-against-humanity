Sequel.migration do
  up do
    add_column :players, :discord_nick, String
  end

  down do
    drop_column :players, :discord_nick 
  end
end
