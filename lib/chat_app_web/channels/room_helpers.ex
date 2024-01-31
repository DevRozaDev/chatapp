defmodule ChatAppWeb.RoomHelpers do
  alias ChatAppWeb.Auth.Token
  alias ChatApp.ChatDB
  alias ChatApp.Chat.Message
  require Logger

  import Phoenix.Channel
  import Phoenix.Socket

  def send_message(content, socket) do
    with {:ok, %Message{} = %{inserted_at: timestamp, id: message_id}} <-
           ChatDB.create_message(%{
             chat_id: socket.assigns.chat_id,
             nickname_id: socket.assigns.nickname_id,
             content: content
           }) do
      broadcast(socket, "shout", %{
        "content" => content,
        "author" => socket.assigns.user,
        timestamp: timestamp,
        id: message_id
      })

      {:noreply, socket}
    else
      error ->
        Logger.debug("Invalid chat message from client", additonal: error)
        {:noreply, socket}
    end
  end

  # Add authorization logic here as required.
  def authorization(chat_id, %{"token" => token}, socket) do
    chat_id = String.to_integer(chat_id)

    case Token.verify(token, max_age: :infinity) do
      {:ok, %{nickname_id: nickname_id, chat_id: ^chat_id, nickname: nickname}} ->
        {:ok, timestamp} = DateTime.now("Etc/UTC")

        socket =
          assign(socket, :user, nickname)
          |> assign(:nickname_id, nickname_id)
          |> assign(:chat_id, chat_id)
          |> assign(:join_time, timestamp)

        {:ok, socket}

      # Don't give unnecessary information to potential attacker
      {:ok, _params} ->
        {:error, :invalid_token}

      {:error, _} ->
        {:error, :invalid_token}
    end
  end

  def authorization(_room_id, _params, _socket) do
    {:error, :invalid_token}
  end
end
