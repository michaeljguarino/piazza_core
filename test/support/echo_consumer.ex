defmodule Piazza.EchoConsumer do
  use Piazza.PubSub.Consumer,
    broadcaster: Piazza.TestBroadcaster,
    max_demand: 5

  def handle_event(%{source_pid: pid} = event) do
    send(pid, {:event, event})
  end
end