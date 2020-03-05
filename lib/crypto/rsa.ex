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

  @sep "::"

  @spec encrypt(binary, RSAPrivateKey.t) :: {:ok, binary} | :error
  def encrypt(str, %RSAPrivateKey{} = priv) when is_binary(str) do
    {:ok, aes_256_key} = ExCrypto.generate_aes_key(:aes_256, :bytes)

    with {:ok, encrypted_key} <- ExPublicKey.encrypt_private(aes_256_key, priv),
         {:ok, signature} <- ExPublicKey.sign(str, priv),
         {:ok, encryption_tuple} <- ExCrypto.encrypt(aes_256_key, str),
      do: {:ok, "#{encrypted_key}#{@sep}#{Base.url_encode64(signature)}#{@sep}#{encode_payload(encryption_tuple)}"}
  end

  @spec decrypt(binary, RSAPublicKey.t) :: {:ok, binary} | :error
  def decrypt(str, %RSAPublicKey{} = pub) when is_binary(str) do

    with [encrypted_key, signature, encrypted_payload] <- String.split(str, @sep),
         {:ok, decrypted_key} <- ExPublicKey.decrypt_public(encrypted_key, pub),
         {iv, cipher} <- decode_payload(encrypted_payload),
         {:ok, decrypted} <- ExCrypto.decrypt(decrypted_key, iv, cipher),
         {:ok, true} <- ExPublicKey.verify(decrypted, Base.url_decode64!(signature), pub) do
      {:ok, decrypted}
    else
      _ -> :error
    end
  end


  defp encode_payload({iv, txt}) when byte_size(iv) == 16 do
    Base.url_encode64(iv <> txt)
  end

  defp decode_payload(payload) do
    decoded = Base.url_decode64!(payload)
    len = byte_size(decoded)
    {binary_part(decoded, 0, 16), binary_part(decoded, 16, len - 16)}
  end
end