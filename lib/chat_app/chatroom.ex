defmodule ChatApp.Chatroom do
  alias ChatApp.Chatroom.Instance, as: Instance

  @doc """
  Creates a new room, with key room-name.
  """
  def create_chatroom(id) do
    name = {:via, Registry, {ChatApp.Chatroom.Registry, "room-#{id}"}}

    case ChatApp.Chatroom.Instance.start(id, name: name, timeout: 30) do
      {:ok, _} -> :ok
      {:error, details} -> {:error, details}
    end
  end

  @doc """
  Returns true if chat isn't archived.
  """
  @spec chat_active?(integer) :: boolean
  def chat_active?(id) do
    case Registry.lookup(ChatApp.Chatroom.Registry, "room-#{id}") do
      [{_pid, _value} | []] -> true
      [] -> false
    end
  end

  @doc """
  Finds the server of the correct room and returns a new nickname for it.
  """
  def new_nickname(chatroom) do
    case Registry.lookup(ChatApp.Chatroom.Registry, "room-#{chatroom}") do
      [{pid, _value} | []] -> Instance.new_name(pid)
      [] -> {:error, :nonexistent_chatroom}
    end
  end
end
