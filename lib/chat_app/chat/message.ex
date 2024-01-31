defmodule ChatApp.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string
    field :chat_id, :integer

    belongs_to :nickname, ChatApp.Chat.Nickname
    timestamps(type: :utc_datetime)
  end

  @doc false
  def create_changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :chat_id, :nickname_id])
    |> validate_required([:content])
    |> foreign_key_constraint(:chat_id)
    |> foreign_key_constraint(:nickname_id)
    |> validate_length(:content, min: 1, max: 1000)
  end
end
