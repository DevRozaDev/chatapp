defmodule ChatAppWeb.RoomChannel do
  use ChatAppWeb, :channel
  import ChatAppWeb.RoomHelpers
  require Logger

  def join("room:" <> room_id, payload, socket) do
    case authorization(room_id, payload, socket) do
      {:ok, socket} ->
        {:ok, socket}

      {:error, :invalid_token} ->
        {:error, %{reason: "no valid token provided"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:*).
  def handle_in("shout", %{"content" => content}, socket) do
    if ChatApp.Chatroom.chat_active?(socket.assigns.chat_id) do
      send_message(content, socket)
    else
      {:stop, :normal, socket}
    end
  end
end
