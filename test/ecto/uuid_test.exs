defmodule Piazza.Ecto.UUIDTest do
  use ExUnit.Case
  alias Piazza.Ecto.UUID

  describe "#generate_monotonic" do
    test "It won't bork" do
      uuid = UUID.generate_monotonic() |> IO.inspect()
      {:ok, {timestamp, rand}} = UUID.decode(uuid)

      assert is_integer(timestamp)
      assert is_binary(rand)
    end
  end
end
