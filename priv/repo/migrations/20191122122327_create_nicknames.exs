defmodule ChatApp.Repo.Migrations.CreateNicknames do
  use Ecto.Migration

  def change do
    create table(:nicknames) do
      add :nickname, :string, null: false
    end

    create unique_index(:nicknames, [:nickname])
  end
end
