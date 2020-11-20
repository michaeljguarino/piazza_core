defmodule Piazza.Ecto.Types.ErlangTest do
  use ExUnit.Case
  alias Piazza.Ecto.Types.Erlang

  describe "#load/1" do
    test "It can decode encoded terms" do
      {:ok, dump} = Erlang.dump(%{a: "map"})
      {:ok, %{a: "map"}} = Erlang.load(dump)
    end

    test "It returns error for invalid binaries" do
      :error = Erlang.load("invalid")
    end
  end
end