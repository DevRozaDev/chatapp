defmodule ChatApp.Chatroom.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {ChatApp.Chatroom.NameSource, name: ChatApp.Chatroom.Names.Default, source: "default.txt"},
      {ChatApp.Chatroom.Listener, name: ChatApp.Chatroom.Listener},
      {Registry,
       keys: :unique, name: ChatApp.Chatroom.Registry, listeners: [ChatApp.Chatroom.Listener]},
      {ChatApp.Chatroom.RestartRooms, name: ChatApp.Chatroom.RestartRooms, mode: :restart}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
