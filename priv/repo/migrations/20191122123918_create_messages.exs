defmodule ChatApp.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :text, null: false
      add :nickname_id, references(:nicknames, on_delete: :nothing), null: false
      add :chat_id, references(:chats, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:nickname_id])
    create index(:messages, [:chat_id])
  end
end
