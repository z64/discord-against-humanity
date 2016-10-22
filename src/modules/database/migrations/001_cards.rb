Sequel.migration do
  up do
    create_table(:expansions) do
      primary_key :id
      String :name, unique: true, null: false
      String :authors
    end

    create_table(:questions) do
      primary_key :id
      String :text, null: false
      Integer :answers, default: 1
      foreign_key :expansion_id, :expansions, on_delete: :cascade
    end

    create_table(:answers) do
      primary_key :id
      String :text, null: false
      foreign_key :expansion_id, :expansions, on_delete: :cascade
    end
  end
end
