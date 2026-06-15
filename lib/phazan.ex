defmodule Phazan do
  # todo: move to config
  # @tokens ["BTC", "ETH", "HYPE", "SOL", "ZEC", "PUMP", "XMR", "PURR", "LINK", "ENA", "KNTQ"]
  @tokens ["BNB"]
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

  # def parse_snapshot([h | tail], acc, coin) do
  #   close_price = Float.parse(Map.get(h, "c")) |> elem(0)

  #   parse_snapshot(tail, [close_price] ++ acc, coin)
  # end

  # def parse_snapshot([], acc, coin) do
  #   price = Enum.fetch(acc, 0) |> elem(1)

  #   calculate(acc, price, coin)
  # end

  # def parse_snapshot(nil, _acc, coin) do
  #   IO.puts("Not found candles for $#{coin}")
  # end

  def fetch_snapshot(coin) do
    # BinanceAPI.get_snapshot(coin)
    case HyperLiquidAPI.get_snapshot(coin) |> Utils.parse_snapshot_response([], "hl") do
      nil ->
        BinanceAPI.get_snapshot(coin) |> elem(0) |> Utils.parse_snapshot_response([], "binance")

      snapshot ->
        snapshot
    end
  end

  def get_snapshot(coin) do
    parsed = fetch_snapshot(coin)
    [price | _] = parsed

    calculate(parsed, price, coin)
  end

  def parse_spot_meta([h | tail]) do
    get_snapshot(h)

    parse_spot_meta(tail)
  end

  def parse_spot_meta([]) do
    IO.puts("No spot meta data, waiting 24 hours...")

    # wait 24 hours
    Process.sleep(@sleep_timeout)

    parse_spot_meta(@tokens)
  end

  def main(_) do
    parse_spot_meta(@tokens)
  end
end
