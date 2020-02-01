defmodule Piazza.Crypto.License do
  use GenServer
  alias Piazza.Crypto.RSA

  defmodule State, do: defstruct [:license, :on_failure, :on_verify, :public_key, :parsed]
  @interval 60 * 1000

  def start_link(license, public_key, on_failure, on_verify \\ fn _, state -> state end)
        when is_function(on_failure) and is_function(on_verify) do
    GenServer.start_link(__MODULE__, [license, public_key, on_failure, on_verify], name: __MODULE__)
  end

  def fetch(pid \\ __MODULE__), do: GenServer.call(pid, :fetch)

  def init([license, public_key, on_failure, on_verify]) do
    :timer.send_interval(@interval, :verify)
    send self(), :verify
    {:ok, %State{
        license: license,
        public_key: extract_key(public_key),
        on_failure: on_failure,
        on_verify: on_verify}}
  end

  def handle_call(:fetch, _, %State{parsed: parsed} = state),
    do: {:reply, parsed, state}

  def handle_info(
    :verify,
    %State{license: license, on_failure: on_failure, on_verify: on_verify, public_key: pub} = state
  ) do
    case RSA.decrypt(license, pub) do
      {:ok, res} ->
        {:noreply, update_state(on_verify.(res), state)}
      error ->
        on_failure.(error)
        {:noreply, state}
    end
  end

  defp update_state({parsed, license}, state), do: %{state | parsed: parsed, license: license}
  defp update_state(parsed, state), do: %{state | parsed: parsed}

  defp extract_key({atom, name}) do
    :code.priv_dir(atom)
    |> Path.join(name)
    |> File.read!()
    |> extract_key()
  end
  defp extract_key(pem) when is_binary(pem), do: ExPublicKey.loads!(pem)
end