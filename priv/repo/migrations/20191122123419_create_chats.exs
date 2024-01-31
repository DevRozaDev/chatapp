defmodule ChatApp.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :topic, :string, null: false
      add :category_id, references(:categories, on_delete: :nothing), null: false
      add :archived, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
