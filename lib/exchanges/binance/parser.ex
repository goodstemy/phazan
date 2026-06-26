defmodule Exchanges.Binance.Parser do
  def parse_result([h | tail], acc) do
    [_, _, _, _, close_price, _, _ | _] = h

    parse_result(tail, [close_price] ++ acc)
  end

  def parse_result([], acc), do: Enum.reverse(acc)
  def parse_result(%{}, _), do: nil
end
