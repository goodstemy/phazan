defmodule Utils do
  def parse_snapshot_response([h | tail], acc, exchange = "hl") do
    case exchange do
      "hl" ->
        close_price = Float.parse(Map.get(h, "c")) |> elem(0)
        parse_snapshot_response(tail, [close_price] ++ acc, exchange)

      "binance" ->
        # TODO
        nil
    end
  end

  def parse_snapshot_response([], acc, _), do: acc
  def parse_snapshot_response(nil, _, _), do: nil
end
