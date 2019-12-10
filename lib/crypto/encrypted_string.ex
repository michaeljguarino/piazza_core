defmodule Piazza.Ecto.EncryptedString do
  @moduledoc """
  Implements at rest encryption for ecto fields.  The encrypted field will be
  placed into a b64 encoded protobuf message, for ease of migration
  as additional features like kms integration or key rotation are introduced.
  """
  use Ecto.Type
  @header "%ENC%"

  def type, do: :binary

  def cast(str) when is_binary(str), do: {:ok, str}
  def cast(_), do: :error

  def load(@header <> str) do
    with {:ok, b64ed} <- Base.url_decode64(str),
         %{keyed: keyed} <- Envelope.decode(b64ed),
         {:ok, {initv, cipher}} <- decode_payload(keyed) do
      ExCrypto.decrypt(key(), initv, cipher)
    end
  end
  def load(str) when is_binary(str), do: {:ok, str}
  def load(_), do: :error

  def dump(str) when is_binary(str) do
    with {:ok, {initv, cipher}} <- ExCrypto.encrypt(key(), str),
         {:ok, encoded} <- encode_payload(initv, cipher) do
      {:ok, @header <>
            (Envelope.new(keyed: encoded)
            |> Envelope.encode()
            |> Base.url_encode64())}
    end
  end
  def dump(_), do: :error

  defp key() do
    {:ok, key} = Application.get_env(:piazza_core, :aes_key) |> Base.url_decode64()
    key
  end

  def encode_payload(initv, cipher), do: {:ok, Base.url_encode64(initv <> cipher)}

  def decode_payload(b64str) do
    with {:ok, decoded} <- Base.url_decode64(b64str) do
      decoded_length = byte_size(decoded)
      iv = Kernel.binary_part(decoded, 0, 16)
      cipher_text = Kernel.binary_part(decoded, 16, decoded_length - 16)
      {:ok, {iv, cipher_text}}
    end
  end
end
