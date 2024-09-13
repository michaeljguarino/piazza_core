defmodule Piazza.PubSub.Broadcaster do
  defmacro __using__(_) do
    quote do
      use GenStage

      @doc "Starts the broadcaster."
      def start_link(_args) do
        GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
      end

      @doc "Sends an event asynchronously"
      def notify(event) do
        GenStage.cast(__MODULE__, {:notify, %{event | source_pid: event.source_pid || self()}})
      end

      ## Callbacks
      def init(:ok) do
        {:producer, {:queue.new, 0}, dispatcher: GenStage.BroadcastDispatcher}
      end

      def handle_cast({:notify, event}, {queue, pending_demand}) do
        queue = :queue.in(event, queue)
        dispatch_events(queue, pending_demand, [])
      end

      def handle_demand(incoming_demand, {queue, pending_demand}) do
        dispatch_events(queue, incoming_demand + pending_demand, [])
      end

      defp dispatch_events(queue, 0, events) do
        {:noreply, Enum.reverse(events), {queue, 0}}
      end

      defp dispatch_events(queue, demand, events) do
        case :queue.out(queue) do
          {{:value, event}, queue} ->
            dispatch_events(queue, demand - 1, [event | events])
          {:empty, queue} ->
            {:noreply, Enum.reverse(events), {queue, demand}}
        end
      end
    end
  end
end
