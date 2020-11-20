defmodule Piazza.Ecto.Types.Erlang do
  use Ecto.Type

  def type, do: :binary

  def cast(t), do: {:ok, t}

  def load(str) do
    {:ok, :erlang.binary_to_term(str)}
  rescue
    _ -> :error
  end

  def dump(t), do: {:ok, :erlang.term_to_binary(t)}
end