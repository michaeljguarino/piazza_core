defmodule Piazza.Crypto.RSATest do
  use ExUnit.Case
  alias Piazza.Crypto.RSA

  describe "#encrypt" do
    test "A keypair can encrypt (then decrypt)" do
      {:ok, {priv, pub}} = RSA.generate_keypair()
      test_str = "something secret"
      {:ok, val} = RSA.encrypt(test_str, priv)

      assert val != test_str

      {:ok, dec} = RSA.decrypt(val, pub)

      assert dec == test_str
    end

    test "It fails if tampered with" do
      {:ok, {priv, pub}} = RSA.generate_keypair()
      test_str = "something secret"
      {:ok, val} = RSA.encrypt(test_str, priv)

      [enc_key , sig, _] = String.split(val, "::")
      {:ok, decrypted_key} = ExPublicKey.decrypt_public(enc_key, pub)

      {:ok, {iv, cipher}} = ExCrypto.encrypt(decrypted_key, "tampered string")
      fake_license = "#{enc_key}::#{sig}::#{Base.url_encode64(iv <> cipher)}"
      :error = RSA.decrypt(fake_license, pub)
    end
  end

  describe "#pem_encode" do
    test "It can properly pem encode a keypair" do
      {:ok, keypair} = RSA.generate_keypair()

      {:ok, {priv, pub}} = RSA.pem_encode(keypair)

      assert priv =~ "BEGIN RSA PRIVATE KEY"
      assert pub =~ "BEGIN RSA PUBLIC KEY"
    end
  end
end