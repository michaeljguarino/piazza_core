defmodule Piazza.Crypto.RSA do
  alias ExPublicKey.{
    RSAPrivateKey,
    RSAPublicKey
  }
  @type keypair :: {RSAPrivateKey.t, RSAPublicKey.t}

  @spec generate_keypair() :: {:ok, keypair} | {:error, term}
  def generate_keypair() do
    with {:ok, private} <- ExPublicKey.generate_key(),
         {:ok, public} <- ExPublicKey.public_key_from_private_key(private),
      do: {:ok, {private, public}}
  end

  @spec pem_encode(keypair) :: {:ok, {binary, binary}} | {:error, term}
  def pem_encode({%RSAPrivateKey{} = pk, %RSAPublicKey{} = pub}) do
    with {:ok, pk_pem} <- ExPublicKey.pem_encode(pk),
         {:ok, pub_pem} <- ExPublicKey.pem_encode(pub),
      do: {:ok, {pk_pem, pub_pem}}
  end

  @spec encrypt(binary, RSAPrivateKey.t) :: {:ok, binary} | :error
  def encrypt(str, %RSAPrivateKey{} = priv) when is_binary(str) do
    ExPublicKey.encrypt_private(str, priv)
  end

  @spec decrypt(binary, RSAPublicKey.t) :: {:ok, binary} | :error
  def decrypt(str, %RSAPublicKey{} = pub) when is_binary(str) do
    ExPublicKey.decrypt_public(str, pub)
  end
end