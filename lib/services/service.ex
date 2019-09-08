defmodule Piazza.Service do
  defmacro __using__(repo: repo, broadcaster: broadcaster) do
    quote do
      defmacro __using__(_) do
        module = __MODULE__
        quote do
          import unquote(module)
        end
      end

      def start_transaction(), do: Ecto.Multi.new()

      def add_operation(multi, name, fun) when is_function(fun) do
        Ecto.Multi.run(multi, name, fn _, params ->
          fun.(params)
        end)
      end

      def execute(multi, opts \\ []) do
        with {:ok, result} <- unquote(repo).transaction(multi) do
          case Map.new(opts) do
            %{extract: operation} -> {:ok, result[operation]}
            _ -> {:ok, result}
          end
        else
          {:error, _, reason, _} -> {:error, reason}
          {:error, reason} -> {:error, reason}
        end
      end

      def ok(res), do: {:ok, res}

      def when_ok({:ok, resource}, :insert), do: unquote(repo).insert(resource)
      def when_ok({:ok, resource}, :update), do: unquote(repo).update(resource)
      def when_ok({:ok, resource}, :delete), do: unquote(repo).delete(resource)
      def when_ok({:ok, resource}, fun) when is_function(fun), do: {:ok, fun.(resource)}
      def when_ok(error, _), do: error

      def notify(broadcaster, event_type, resource, additional \\ %{}) do
        Map.new(additional)
        |> Map.put(:item, resource)
        |> event_type.__struct__()
        |> broadcaster.notify()
        |> case do
          :ok   -> {:ok, resource}
          _error -> {:error, :internal_error}
        end
      end

      def timestamped(map) do
        map
        |> Map.put(:inserted_at, DateTime.utc_now())
        |> Map.put(:updated_at, DateTime.utc_now())
      end

      def handle_notify(event_type, resource, additional \\ %{}),
        do: notify(unquote(broadcaster), event_type, resource, additional)
    end
  end
end