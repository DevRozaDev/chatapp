defmodule ChatAppWeb.ChatHelpers do
  alias ChatApp.ChatDB
  alias ChatApp.Chat.Nickname

  def get_existing_nickname_id(nickname) do
    case ChatDB.get_nickname(nickname) do
      nil ->
        {:ok, %Nickname{id: id}} = ChatDB.create_nickname(%{nickname: nickname})
        id

      %Nickname{id: id} ->
        id
    end
  end
end
