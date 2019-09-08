defmodule Piazza.PubSub.Event do
  defmacro __using__(_) do
    quote do
      defstruct [:item, :actor, :context, :source_pid]
    end
  end
end