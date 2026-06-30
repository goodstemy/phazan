# Phazan 🪶

**Phazan tells your where to buy**

Simple project for elixir learning. Using Hyperliquid API to get snapshots of last 100 days every 24h. Indicates for best spot entries to buy and sell based on:

- Simple Moving Average (SMA)
- Exponential Moving Average (EMA)
- Relative Strength Index (RSI)

## Installation

```elixir
# install deps
mix deps.get

# dev
mix run --no-halt

# prod
mix release && _build/dev/rel/phazan/bin/phazan start
```

#### Example output

```
BTC = $73427.0
|
ETH = $2013.7
|
HYPE = $65.475
|
🟥 Sell signal for HYPE: EMA < price and RSI > 70
|
SOL = $82.01
|
ZEC = $527.35
|
PUMP = $0.00174
|
XMR = $369.84
|
PURR = $0.10719
|
LINK = $8.9748
|
No spot meta data, waiting 24 hours...
```
