defmodule ChatApp.Chat.Nickname do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nicknames" do
    field :nickname, :string
    has_many :messages, ChatApp.Chat.Message
  end

  @doc false
  def create_changeset(nickname, attrs) do
    nickname
    |> cast(attrs, [:nickname])
    |> validate_required([:nickname])
    |> unique_constraint(:nickname)
  end
end
