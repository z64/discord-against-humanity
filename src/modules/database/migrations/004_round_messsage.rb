Sequel.migration do
  up do
    add_column :rounds, :message_id, Integer, unique: true
  end

  down do
    drop_column :rounds, :message_id
  end
end
