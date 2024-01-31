defmodule ChatApp.Chatroom.RestartRooms do
  use Task

  alias ChatApp.ChatDB

  require Logger

  def start_link(args) do
    case Keyword.fetch(args, :mode) do
      {:ok, :restart} ->
        Task.start_link(__MODULE__, :run_restart, [])

      {:ok, :close} ->
        Task.start_link(__MODULE__, :run_close, [])

      {:ok, other} ->
        raise ArgumentError, message: "invalid mode #{inspect(other)}"

      # Run default
      :error ->
        Logger.info("#{Atom.to_string(__MODULE__)} mode not supplied, launching with default")
        Task.start_link(__MODULE__, :run_close, [])
    end
  end

  def run_restart() do
    try do
      case ChatDB.get_chats(%{archived: false}) do
        chats when is_list(chats) ->
          for %{id: id} <- chats do
            ChatApp.Chatroom.create_chatroom(id)
          end

        other ->
          Logger.error("Failed to retrieve active chats from DB: #{inspect(other)}")
          Process.sleep(1000)
          run_restart()
      end
    rescue
      e in DBConnection.ConnectionError ->
        Logger.error("DB Connection failed: #{inspect(e)}")
        Process.sleep(1000)
        run_restart()
    end
  end

  def run_close() do
    try do
      {num, nil} = ChatDB.close_all_chats()
      Logger.info("Closed #{num} chats on startup.")
    rescue
      e in DBConnection.ConnectionError ->
        Logger.error("DB Connection failed: #{inspect(e)}")
        Process.sleep(1000)
        run_close()
    end
  end
end
