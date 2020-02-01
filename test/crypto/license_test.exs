defmodule Piazza.Crypto.LicenseTest do
  use ExUnit.Case
  alias Piazza.Crypto.{License, RSA}

  describe "#on_verify" do
    test "Valid licenses call the on_verify hook" do
      {:ok, {priv, pub}} = RSA.generate_keypair()
      {:ok, license} = RSA.encrypt("license str", priv)

      me = self()
      on_verify = fn res ->
        send me, res
        res
      end
      {:ok, pub_pem} = ExPublicKey.pem_encode(pub)
      {:ok, _} = License.start_link(license, pub_pem, fn _ -> :ok end, on_verify)

      {:ok, expected} = RSA.decrypt(license, pub)
      assert_receive ^expected
    end
  end

  describe "#fetch" do
    test "You can fetch parsed valid licenses" do
      {:ok, {priv, pub}} = RSA.generate_keypair()
      {:ok, license} = RSA.encrypt("license str", priv)

      me = self()
      on_verify = fn res ->
        send me, res
        res
      end
      {:ok, pub_pem} = ExPublicKey.pem_encode(pub)
      {:ok, pid} = License.start_link(license, pub_pem, fn _ -> :ok end, on_verify)

      {:ok, expected} = RSA.decrypt(license, pub)
      assert_receive ^expected

      "license str" = License.fetch(pid)
    end
  end

  describe "#on_failure" do
    test "Invalid licenses call the on_failure hook" do
      {:ok, {_, pub}} = RSA.generate_keypair()

      me = self()
      on_failure = fn res -> send me, res end
      {:ok, pub_pem} = ExPublicKey.pem_encode(pub)
      {:ok, _} = License.start_link("bogus", pub_pem, on_failure)

      assert_receive :error
    end
  end
end