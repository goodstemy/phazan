defmodule HyperLiquidAPI do
  # todo: move to config
  @shift_days -100

  def get_snapshot(coin) do
    IO.puts("$#{coin} getting HL snapshot...")

    Req.post!(
      "https://api.hyperliquid.xyz/info",
      headers: [{"Content-Type", "application/json"}],
      json: %{
        "type" => "candleSnapshot",
        "req" => %{
          "coin" => coin,
          "interval" => "1d",
          "startTime" =>
            DateTime.utc_now()
            |> DateTime.shift(day: @shift_days)
            |> DateTime.to_unix(:millisecond),
          "endTime" => DateTime.utc_now() |> DateTime.to_unix(:millisecond)
        }
      }
    ).body
  end
end
