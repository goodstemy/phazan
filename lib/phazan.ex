defmodule Phazan do
  alias Exchanges.Binance
  alias Exchanges.Hyperliquid

  # todo: move to config
  @tokens ["BTC", "ETH", "HYPE", "SOL", "ZEC", "PUMP", "XMR", "PURR", "LINK", "ENA", "KNTQ"]
  @sma_window 20
  @ema_window 50
  @rsi_window 14
  @rsi_overbought 70
  @rsi_oversold 30
  @sleep_timeout 24 * 60 * 60 * 1000

  def calculate(acc, price, coin) do
    sma = Indicators.calculate_sma(acc, @sma_window)
    ema = Indicators.calculate_ema(acc, @ema_window)
    rsi = Indicators.calculate_rsi(acc, @rsi_window)

    IO.puts("$#{String.upcase(coin)} sma: #{sma}, ema: #{ema}, rsi: #{rsi}")

    if sma > price and ema > price and rsi < @rsi_oversold do
      IO.puts(
        "#{coin} = $#{price}\n🟩 Buy signal for $#{coin}: EMA > price and RSI < #{@rsi_oversold}\n|"
      )

      # todo: send signal to tg bot
    end

    if sma < price and ema < price and rsi > @rsi_overbought do
      IO.puts(
        "#{coin} = $#{price}\n🟥 Sell signal for $#{coin}: EMA < price and RSI > #{@rsi_overbought}\n|"
      )

      # todo: send signal to tg bot
    end
  end

  def fetch_snapshot(coin) do
    case Hyperliquid.Rest.get_snapshot(coin) do
      nil ->
        Binance.Rest.get_snapshot(coin)

      snapshot ->
        snapshot
    end
  end

  def get_snapshot(coin) do
    case fetch_snapshot(coin) do
      nil ->
        IO.puts("Not found any data for $#{String.upcase(coin)}")

      snapshot ->
        [current_price | _] = snapshot

        calculate(snapshot, current_price, coin)
    end
  end

  def parse_spot_meta([h | tail]) do
    get_snapshot(h)

    parse_spot_meta(tail)
  end

  def parse_spot_meta([]) do
    IO.puts("🎬 THE END. Waiting 24 hours...")

    # wait 24 hours
    Process.sleep(@sleep_timeout)

    parse_spot_meta(@tokens)
  end

  def start_ws() do
    children = [
      {Hyperliquid.Ws, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  def start_rest(), do: parse_spot_meta(@tokens)

  def main(_) do
    start_ws()
    # start_rest()

    Process.sleep(@sleep_timeout)
  end
end
