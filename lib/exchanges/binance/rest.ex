defmodule Exchanges.Binance.Rest do
  alias Exchanges.Binance.Parser

  # todo: move to config
  @shift_days -100

  def get_snapshot(coin) do
    IO.puts("$#{coin} getting Binance snapshot...")

    Req.get!(
      "https://api.binance.com/api/v3/klines?" <>
        "&symbol=#{coin}USDT" <>
        "&interval=1d" <>
        "&startTime=#{DateTime.utc_now() |> DateTime.shift(day: @shift_days) |> DateTime.to_unix(:millisecond)}" <>
        "&endTime=#{DateTime.utc_now() |> DateTime.to_unix(:millisecond)}"
    ).body
    |> Parser.parse_result([])
  end
end
