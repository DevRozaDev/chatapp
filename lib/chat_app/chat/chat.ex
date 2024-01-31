defmodule ChatApp.Chat.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chats" do
    field :archived, :boolean, default: false
    field :category_id, :integer
    field :topic, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def create_changeset(chat, attrs) do
    chat
    |> cast(attrs, [:topic, :category_id])
    |> validate_required([:topic, :category_id])
    |> foreign_key_constraint(:category_id)
    |> validate_length(:topic, min: 10, max: 50)
  end
end
