defmodule Piazza.Ecto.UUID do
  def generate_monotonic() do
    timestamp = :os.system_time(:millisecond)
    random = :crypto.strong_rand_bytes(10)
    <<u0::48, _::4, u1::12, _::2, u2::62>> = <<timestamp::48, random::binary>>
    {:ok, res} = Ecto.UUID.load(<<u0::48, 4::4, u1::12, 2::2, u2::62>>)
    res
  end

  def decode(<<timestamp::48, rand::binary>>) do
    {:ok, {timestamp, rand}}
  end
  def decode(_), do: :error
end