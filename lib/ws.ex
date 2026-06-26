defmodule WsClient do
  @ping_timeout 60_000

  def start_link(state),
    do: WebSockex.start_link("wss://api.hyperliquid.xyz/ws", __MODULE__, state)

  def handle_connect(_conn, state) do
    IO.puts("Connected!")

    Process.send_after(self(), :send_subscribe, 0)
    Process.send_after(self(), :send_ping, @ping_timeout)
    {:ok, state}
  end

  def handle_info(:send_subscribe, state) do
    msg = %{
      method: "subscribe",
      subscription: %{
        type: "l2Book",
        coin: "BTC"
      }
    }

    {:reply, {:text, JSON.encode!(msg)}, state}
  end

  def handle_info(:send_ping, state) do
    IO.puts("Sending ping (heartbeat)")
    ping = JSON.encode!(%{method: "ping"})

    Process.send_after(self(), :send_ping, @ping_timeout)

    {:reply, {:text, ping}, state}
  end

  def handle_info(_msg, state), do: {:ok, state}

  def parse_book(msg) do
    IO.inspect("parse_book #{msg}")
    # inspect("Parse_book #{Map.get(msg, "data")}")
  end

  def handle_frame({_type, msg}, state) do
    parsed = JSON.decode!(msg)

    # don't want to use pattern matching here...
    case Map.get(parsed, "channel") do
      "pong" ->
        {:ok, state}

      "l2Book" ->
        parse_book(parsed)
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
