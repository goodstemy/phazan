defmodule Exchanges.Hyperliquid.Parser do
  def parse_snapshot_result([h | tail], acc) do
    close_price = Float.parse(Map.get(h, "c")) |> elem(0)

    parse_snapshot_result(tail, [close_price] ++ acc)
  end

  def parse_snapshot_result([], acc), do: acc
  def parse_snapshot_result(nil, _), do: nil

  def parse_book_message(_book) do
    # todo
  end
end
