defmodule Piazza.Ecto.EncryptedStringTest do
  use ExUnit.Case
  alias Piazza.Ecto.EncryptedString

  describe "#dump/load" do
    test "The encryption is invertable" do
      {:ok, "%ENC%" <> _ = encrypted} = EncryptedString.dump("super secret")
      refute encrypted == "super secret"

      {:ok, "super secret"} = EncryptedString.load(encrypted)
    end

    test "It will bypass strings without the enc header for backwards compatibility" do
      {:ok, "not secret"} = EncryptedString.load("not secret")
    end
  end
end