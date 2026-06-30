defmodule Exchanges.Hyperliquid.Parser do
  def parse_snapshot_result([h | tail], acc) do
    {close_price, _} = Float.parse(Map.get(h, "c"))
    parse_snapshot_result(tail, [close_price] ++ acc)
  end

  def parse_snapshot_result([], acc), do: acc
  def parse_snapshot_result(nil, _), do: nil

  def parse_book_message(book) do
    levels = get_in(book, ["data", "levels"])

    Enum.flat_map_reduce(levels, [], fn l, acc -> {l, l ++ acc} end)
    |> elem(0)
    |> Enum.sort(
      &(Float.parse(&1["px"])
        |> elem(0) <
          Float.parse(&2["px"])
          |> elem(0))
    )
  end
end
