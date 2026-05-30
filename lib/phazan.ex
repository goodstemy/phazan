defmodule Phazan do
  # todo: move to config
  @tokens ["BTC", "ETH", "HYPE", "SOL", "ZEC", "PUMP", "XMR", "PURR", "LINK"]
  @sma_window 20
  @ema_window 50
  @rsi_window 14
  @rsi_overbought 70
  @rsi_oversold 30

  def calculate(acc, price, coin) do
    sma = Indicators.calculate_sma(acc, @sma_window)
    ema = Indicators.calculate_ema(acc, @ema_window)
    rsi = Indicators.calculate_rsi(acc, @rsi_window)

    if sma > price and ema > price and rsi < @rsi_oversold do
      IO.puts("🟩 Buy signal for #{coin}: EMA > price and RSI < #{@rsi_oversold}\n|")
      # todo: send signal to tg bot
    end

    if sma < price and ema < price and rsi > @rsi_overbought do
      IO.puts("🟥 Sell signal for #{coin}: EMA < price and RSI > #{@rsi_overbought}\n|")
      # todo: send signal to tg bot
    end
  end

  def parse_snapshot([h | tail], acc, coin) do
    close_price = Float.parse(Map.get(h, "c")) |> elem(0)

    parse_snapshot(tail, [close_price] ++ acc, coin)
  end

  def parse_snapshot([], acc, coin) do
    price = Enum.fetch(acc, 0) |> elem(1)
    IO.puts("#{coin} = $#{price}\n|")

    calculate(acc, price, coin)
  end

  def get_snapshot(coin) do
    HyperLiquidAPI.get_snapshot(coin)
    |> parse_snapshot([], coin)
  end

  def parse_spot_meta([h | tail]) do
    get_snapshot(h)
    parse_spot_meta(tail)
  end

  def parse_spot_meta([]) do
    IO.puts("No spot meta data, waiting 24 hours...")

    # wait 24 hours
    Process.sleep(24 * 60 * 60)

    parse_spot_meta(@tokens)
  end

  def main(_) do
    parse_spot_meta(@tokens)
  end
end
