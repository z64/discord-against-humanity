Sequel.migration do
  up do
    create_table(:expansion_pools) do
      primary_key :id
      foreign_key :game_id, :games, on_delete: :cascade
      foreign_key :expansion_id, :expansions, on_delete: :cascade
    end
  end

  down do
    drop_table(:expansion_pools)
  end
end
