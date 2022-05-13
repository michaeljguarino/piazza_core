defmodule Piazza.Ecto.Schema do
  import Ecto.Changeset
  defmacro __using__(opts \\ []) do
    derive_json = Keyword.get(opts, :derive_json, true)
    quote do
      use Ecto.Schema
      import Ecto.Query
      import Ecto.Changeset
      import Piazza.Ecto.Schema
      import EctoEnum

      @primary_key {:id, :binary_id, autogenerate: true}
      @timestamps_opts [type: :utc_datetime_usec]
      @foreign_key_type :binary_id

      def any(), do: from(r in __MODULE__)

      def for_id(query \\ __MODULE__, id), do: from(r in query, where: r.id == ^id)

      def for_ids(query \\ __MODULE__, ids),
        do: from(r in query, where: r.id in ^ids)

      def selected(query \\ __MODULE__),
        do: from(r in query, select: r)

      defoverridable [any: 0]

      if unquote(derive_json) do
        defimpl Jason.Encoder, for: __MODULE__ do
          def encode(struct, opts) do
            Piazza.Ecto.Schema.mapify(struct)
            |> Jason.Encode.map(opts)
          end
        end
      end
    end
  end

  @url_regex ~r/^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/

  def validate_url(changeset, field) do
    validate_format(changeset, field, @url_regex)
  end

  def put_new_change(changeset, field, fun) when is_function(fun) do
    case get_field(changeset, field) do
      nil -> put_change(changeset, field, fun.())
      _ -> changeset
    end
  end

  def validate_one_present(changeset, [first | _] = fields) do
    case Enum.any?(fields, &present?(changeset, &1)) do
      true -> changeset
      false -> add_error(changeset, first, "One of these fields must be present: #{inspect fields}")
    end
  end

  def present?(changeset, field) do
    value = get_field(changeset, field)
    value && value != ""
  end

  def external_type(module) do
    Macro.underscore(module)
    |> String.split("/")
    |> List.last()
  end

  def mapify(%{__struct__: module} = struct) do
    Map.from_struct(struct)
    |> Enum.map(fn
      {:__meta__, _} -> nil
      {_, %Ecto.Association.NotLoaded{}} -> nil
      {k, v} -> {k, v}
    end)
    |> Enum.filter(& &1)
    |> Map.new()
    |> Map.put(:_type, external_type(module))
  end

  def generate_uuid(changeset, field) do
    case get_field(changeset, field) do
      nil -> put_change(changeset, field, Ecto.UUID.generate())
      _ -> changeset
    end
  end

  defmacro index_name(table, fields) do
    index_name = :"#{table}_#{Enum.join(fields, "_")}_index"
    quote do
      unquote(index_name)
    end
  end

  defmacro boolean_fields(fields, default \\ false) do
    quoted = Enum.map(fields, fn f ->
      quote do
        field(unquote(f), :boolean, default: unquote(default))
      end
    end)

    quote do
      unquote(quoted)
    end
  end
end
