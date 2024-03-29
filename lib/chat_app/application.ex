defmodule ChatApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      ChatApp.Repo,
      # Start the endpoint when the application starts
      ChatAppWeb.Endpoint,
      # Starts a worker by calling: ChatApp.Worker.start_link(arg)
      # {ChatApp.Worker, arg},

      # Starts the chatroom superivision branch
      {ChatApp.Chatroom.Supervisor, name: ChatApp.Chatroom.Supervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ChatApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ChatAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
