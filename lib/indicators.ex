defmodule Indicators do
  def calculate_sma(acc, window) do
    acc = Enum.take(acc, window) |> Enum.reverse()
    sma = Enum.sum(acc) / Enum.count(acc)

    sma
  end

  def calculate_ema(acc, window) do
    sma = calculate_sma(acc, window)
    weighting = 2 / (window + 1)
    do_ema(Enum.take(acc, window), sma, weighting)
  end

  def do_ema([price | tail], prev_ema, weighting) do
    ema = price * weighting + (1 - weighting) * prev_ema
    do_ema(tail, ema, weighting)
  end

  def do_ema([], ema, _weighting) do
    ema
  end

  # this func mostly written by llm :D
  def calculate_rsi(prices, window) when is_list(prices) and window > 0 do
    prices = Enum.reverse(prices)
    changes = changes(prices)

    initial_up = average_positive(changes, window)
    initial_down = average_negative(changes, window)

    if length(changes) < window do
      nil
    else
      rest = Enum.drop(changes, window)

      {final_up, final_down} =
        Enum.reduce(rest, {initial_up, initial_down}, fn change, {up, down} ->
          up   = rma_next(up, max(change, 0), window)
          down = rma_next(down, abs(min(change, 0)), window)
          {up, down}
        end)

      rsi_from_up_down(final_up, final_down)
    end
  end

  defp changes([_]), do: []
  defp changes([prev, curr | tail]) do
    [curr - prev | changes([curr | tail])]
  end

  defp average_positive(changes, window) do
    chunk = Enum.take(changes, window)
    sum_pos = chunk |> Enum.filter(&(&1 > 0)) |> Enum.sum()
    sum_pos / window
  end

  defp average_negative(changes, window) do
    chunk = Enum.take(changes, window)
    sum_neg = chunk |> Enum.filter(&(&1 < 0)) |> Enum.map(&abs/1) |> Enum.sum()
    sum_neg / window
  end

  defp rma_next(prev_rma, value, window) do
    (prev_rma * (window - 1) + value) / window
  end

  defp rsi_from_up_down(up, down) do
    cond do
      down == 0.0 -> 100.0
      up == 0.0   -> 0.0
      true ->
        rs = up / down
        100.0 - (100.0 / (1.0 + rs))
    end
  end
end
