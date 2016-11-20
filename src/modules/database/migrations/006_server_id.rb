Sequel.migration do
  up do
    add_column :games, :server_id, Integer
  end

  down do
    drop_column :games, :server_id
  end
end
