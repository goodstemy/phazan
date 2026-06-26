defmodule Exchanges.Hyperliquid.Ws do
  use WebSockex

  @ping_timeout 60_000

  def start_link(state),
    do: WebSockex.start_link("wss://api.hyperliquid.xyz/ws", __MODULE__, state)

  def handle_connect(_conn, state) do
    IO.puts("#{__MODULE__} WS connected")

    Process.send_after(self(), :send_subscribe, 0)
    Process.send_after(self(), :send_ping, @ping_timeout)
    {:ok, state}
  end

  def handle_info(:send_subscribe, state) do
    msg = %{
      method: "subscribe",
      subscription: %{
        type: "l2Book",
        coin: "BTC",
        nSigFigs: 2,
        fast: false
      }
    }

    {:reply, {:text, JSON.encode!(msg)}, state}
  end

  def handle_info(:send_ping, state) do
    ping = JSON.encode!(%{method: "ping"})

    Process.send_after(self(), :send_ping, @ping_timeout)

    {:reply, {:text, ping}, state}
  end

  def handle_info(_msg, state), do: {:ok, state}

  def handle_frame({_type, msg}, state) do
    msg = JSON.decode!(msg)
    IO.inspect(msg)

    # don't want to use pattern matching here...
    case Map.get(msg, "channel") do
      "pong" ->
        {:ok, state}

      "l2Book" ->
        Exchanges.Hyperliquid.Parser.parse_book_message(msg)
        {:ok, state}

      "subscriptionResponse" ->
        {:ok, state}

      "error" ->
        {:error, state}

      _ ->
        {:ok, state}
    end
  end

  def terminate(reason, state) do
    IO.puts("\nSocket Terminating:\n#{inspect(reason)}\n\n#{inspect(state)}\n")
    exit(:normal)
  end
end
