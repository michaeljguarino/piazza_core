defmodule Piazza.UtilsTest do
  use ExUnit.Case, async: true
  alias Piazza.Utils

  describe "#move_value/3" do
    test "It will move (destructively) a value from one path to another" do
      nested = %{key: %{nested: 1}, other: %{}}

      result = Utils.move_value(nested, [:key, :nested], [:key, :other])

      refute result.key[:nested]
      assert result.key.other == 1
    end
  end

  describe "#copy_value/3" do
    test "It will copy (nondestructively) a value from one keypath to another" do
      nested = %{key: %{nested: 1}, other: %{}}

      result = Utils.copy_value(nested, [:key, :nested], [:key, :other])

      assert result.key.nested == 1
      assert result.key.other == 1
    end
  end
end