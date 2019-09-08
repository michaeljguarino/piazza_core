defmodule Piazza.PubSub.Consumer do
  defmacro __using__(broadcaster: broadcaster, max_demand: demand) do
    quote do
      use ConsumerSupervisor

      def start_link(arg) do
        ConsumerSupervisor.start_link(__MODULE__, arg)
      end

      def init(_arg) do
        children = [%{id: Piazza.Consumers.Worker, start: {Piazza.Consumers.Worker, :start_link, [__MODULE__]}, restart: :temporary}]
        opts = [strategy: :one_for_one, subscribe_to: [{unquote(broadcaster), max_demand: unquote(demand)}]]
        ConsumerSupervisor.init(children, opts)
      end
    end
  end
end

defmodule Piazza.Consumers.Worker do
  def start_link(handler, event) do
    Task.start_link(fn ->
      handler.handle_event(event)
    end)
  end
end