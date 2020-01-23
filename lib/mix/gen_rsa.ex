defmodule Mix.Tasks.Gen.Rsa do
  use Mix.Task
  alias Piazza.Crypto.RSA

  @shortdoc "Creates an rsa key pair"
  def run(_) do
    {:ok, {private, public}} = RSA.generate_keypair()
    dump_pem(public)
    dump_pem(private)
  end

  defp dump_pem(key) do
    {:ok, pem} = ExPublicKey.pem_encode(key)
    IO.puts(pem)
  end
end