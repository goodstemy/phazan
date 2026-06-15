defmodule BinanceAPI do
  @shift_days -100

  def get_snapshot(coin) do
    IO.puts("$#{coin} getting Binance snapshot...")

    result =
      Req.get!(
        "https://api.binance.com/api/v3/klines?" <>
          "&symbol=#{coin}USDT" <>
          "&interval=1d" <>
          "&startTime=#{DateTime.utc_now() |> DateTime.shift(day: @shift_days) |> DateTime.to_unix(:millisecond)}" <>
          "&endTime=#{DateTime.utc_now() |> DateTime.to_unix(:millisecond)}"
      ).body

    IO.puts("ONE")

    result |> elem(0) |> IO.puts()
    # IO.puts(result)

    # result

    case is_map(result) do
      true -> nil
      false -> result |> elem(0)
    end
  end
end
