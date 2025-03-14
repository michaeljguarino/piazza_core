defmodule Piazza.GracefulShutdown do
  @moduledoc """
  Genserver to handle graceful shutdowns of an application. Configure
  with:

  ```
  config :piazza_core,
    shutdown_delay: delay_in_ms
  ```
  And placd it at the beginning of you application supervision tree.
  """
  use GenServer
  require Logger

  @shutdown_delay Application.compile_env(:piazza_core, :shutdown_delay) || 0

  def start_link(args \\ :ok) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    Process.flag(:trap_exit, true)
    {:ok, args}
  end

  def terminate(_, _) do
    Logger.info "Terminating after #{@shutdown_delay} ms"
    :timer.sleep(@shutdown_delay)
  end
end
