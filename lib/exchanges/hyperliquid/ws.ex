defmodule Exchanges.Hyperliquid.Ws do
  use WebSockex

  alias Exchanges.Hyperliquid.Parser

  @token "BTC"
  @ping_timeout 60_000

  def start_link(state),
    do: WebSockex.start_link("wss://api.hyperliquid.xyz/ws", __MODULE__, state)

  def handle_connect(_, state) do
    IO.puts("#{__MODULE__} WS connected")

    state = Map.put_new(state, :candle, nil)

    Process.send_after(self(), :send_subscribe_candles, 0)
    Process.send_after(self(), :send_ping, @ping_timeout)
    {:ok, state}
  end

  def handle_info(:send_subscribe_l2book, state) do
    msg = %{
      method: "subscribe",
      subscription: %{type: "l2Book", coin: @token, nSigFigs: 2, fast: false}
    }

    {:reply, {:text, JSON.encode!(msg)}, state}
  end

  def handle_info(:send_subscribe_candles, state) do
    msg = %{method: "subscribe", subscription: %{type: "candle", coin: @token, interval: "1m"}}

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
    # IO.puts("state: #{inspect(state)}\nmsg: #{inspect(msg)}")
    # IO.puts("")

    # don't want to use pattern matching here...
    case Map.get(msg, "channel") do
      "pong" ->
        {:ok, state}

      "candle" ->
        price = get_in(msg, ["data", "c"])
        state = %{state | candle: price}
        {:ok, state}

      "l2Book" ->
        candle = state.candle
        parent = state.parent

        # IO.puts(
        #   "l2Book: candle=#{inspect(candle)}, parent=#{inspect(parent)}, msg=#{inspect(msg)}, state=#{inspect(state)}"
        # )

        unless(is_nil(candle)) do
          book = Parser.parse_book_message(msg)

          # IO.puts("sending levels: candle=#{inspect(candle)}, book=#{inspect(book)}")

          send(parent, {:levels, candle, book})
        end

        {:ok, state}

      "subscriptionResponse" ->
        type = get_in(msg, ["data", "subscription", "type"])

        if type == "candle" do
          Process.send_after(self(), :send_subscribe_l2book, 0)
        end

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
