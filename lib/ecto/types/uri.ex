defmodule Piazza.Ecto.Types.URI do
  use Ecto.Type

  def type, do: :string

  def cast(url) do
    case URI.parse(url) do
      %URI{scheme: scheme, host: host} when not is_nil(host) and scheme in ["http", "https"] ->
        {:ok, url}
      _ -> :error
    end
  end

  def load(url), do: {:ok, url}

  def dump(url), do: {:ok, url}
end