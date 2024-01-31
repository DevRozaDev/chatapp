defmodule ChatApp.Chatroom.Instance do
  use GenServer

  require Logger
  ## Client API

  @doc """
  Starts the chatroom.
  """
  def start_link(id, opts) do
    timeout =
      case Keyword.fetch(opts, :timeout) do
        {:ok, duration} ->
          duration

        _ ->
          30
      end

    GenServer.start_link(__MODULE__, {id, timeout}, opts)
  end

  def start(id, opts) do
    timeout =
      case Keyword.fetch(opts, :timeout) do
        {:ok, duration} ->
          duration

        _ ->
          30
      end

    GenServer.start(__MODULE__, {id, timeout}, opts)
  end

  @doc """
  Finds an unused name in the current chatroom instance.

  Returns `{:ok, name}` if it manages to find one, `{:error, reason}` otherwise.
  """

  def new_name(server) do
    case GenServer.call(server, :get) do
      nil -> {:error, :name_not_assigned}
      name -> {:ok, name}
    end
  end

  ## Server callbacks
  @impl true
  @spec init({number, :infinity | number}) :: {:ok, list}
  def init({id, timeout}) do
    Logger.debug("Room with id #{id} set their timeout to #{timeout}")
    names = Enum.shuffle(ChatApp.Chatroom.NameSource.get_list(ChatApp.Chatroom.Names.Default))

    timeout =
      case timeout do
        :infinity -> :infinity
        num -> num * 1000 * 60
      end

    Task.async(fn -> activity_check(id, timeout) end)
    {:ok, names}
  end

  # If there's a name returns it, otherwise returns nil
  @impl true
  def handle_call(:get, _from, names) do
    case names do
      [name | rest] ->
        {:reply, name, rest}

      [] ->
        {:reply, nil, names}
    end
  end

  @impl true
  def handle_info({_ref, :finish}, state) do
    {:stop, :normal, state}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp activity_check(id, sleep_time) do
    {:ok, time} = DateTime.now("Etc/UTC")
    Logger.debug("The mysterious id is #{id}")

    try do
      Process.sleep(sleep_time)

      case ChatApp.ChatDB.last_message(id) do
        %{updated_at: message_time} ->
          case DateTime.compare(time, message_time) do
            :lt ->
              Logger.debug("Time #{inspect(time)} < #{inspect(message_time)}}")
              activity_check(id, sleep_time)

            _ ->
              ChatApp.ChatDB.close_chat!(id)
              :finish
          end

        _other ->
          ChatApp.ChatDB.close_chat!(id)
          :finish
      end
    rescue
      DBConnection.ConnectionError ->
        Logger.info("Connection with db for chat #{id} failed")
        activity_check(id, sleep_time)

      e ->
        Logger.info("#{Atom.to_string(__MODULE__)} activity check unknown error: #{inspect(e)}")
    end
  end
end
