defmodule ChatAppWeb.ChatController do
  use ChatAppWeb, :controller
  alias ChatApp.ChatDB
  alias ChatAppWeb.Auth.Token

  import ChatApp.Chatroom
  import ChatAppWeb.ChatHelpers

  action_fallback ChatAppWeb.FallbackController

  @doc """
  Gets all the chats, depending on applied filters.

  Filter types:
  archived: boolean
  contains: string - Topic contains certain phrase
  category: [string] - Chat is in one of the specified categories
  """
  def index(conn, filters) do
    types = %{archived: :boolean, contains: :string, category: {:array, :string}}
    {:ok, filters} = ChatApp.Casts.cast_params(filters, types)

    with chats when is_list(chats) <- ChatDB.get_chats(filters) do
      render(conn, "chats.json", chats: chats)
    end
  end

  def show(conn, %{"id" => chat_id}) do
    chat = ChatDB.get_chat!(chat_id)
    render(conn, "chat.json", chat: chat)
  end

  def join(conn, %{"id" => chat_id}) do
    case new_nickname(chat_id) do
      {:ok, nickname} ->
        nickname_id = get_existing_nickname_id(nickname)
        chat_id = String.to_integer(chat_id)

        conn
        |> put_status(:created)
        |> put_resp_header("location", Routes.chat_path(conn, :join, nickname))
        |> render("chat_identity.json",
          identity: %{
            chat_id: chat_id,
            nickname: nickname,
            token: Token.sign(%{chat_id: chat_id, nickname_id: nickname_id, nickname: nickname})
          }
        )

      {:error, _message} ->
        conn
        |> put_status(404)
        |> put_view(ChatAppWeb.ErrorView)
        |> render(:"404")
    end
  end

  def create(conn, attrs) do
    with {:ok, %{id: id} = chat} <- ChatDB.create_chat(attrs) do
      create_chatroom(id)

      render(conn, "chat.json", chat: chat)
    end
  end

  def get_messages(conn, %{"id" => chat_id}) do
    with messages when is_list(messages) <- ChatDB.get_messages(chat_id) do
      render(conn, "messages.json", %{messages: messages, chat_id: chat_id})
    end
  end
end
