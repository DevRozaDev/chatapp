defmodule ChatApp.Chatroom.Listener do
  use GenServer

  require Logger

  @moduledoc """
  Listener to be used with Registry where keys are unique.
  Maps PIDs to {name, value} tuple to perform additional per-process-restart logic.
  """

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  ## Server callbacks

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_info({:register, _source, name, pid, value}, state) do
    Process.monitor(pid)
    new_state = Map.put(state, pid, {name, value})
    pid = Kernel.inspect(pid)
    Logger.info("Registered #{name} with PID: #{pid}")
    {:noreply, new_state}
  end

  @impl true
  def handle_info({:unregister, _source, name, pid}, state) do
    pid = Kernel.inspect(pid)
    Logger.info("Unregistered #{name} with PID: #{pid}")
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    {{name, value}, new_state} = Map.pop(state, pid)

    Logger.info("Process for name #{name} and value #{value} is down")
    {:noreply, new_state}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
