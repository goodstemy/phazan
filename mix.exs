defmodule Phazan.MixProject do
  use Mix.Project

  def project do
    [
      app: :phazan,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps()
      # escript: escript()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Phazan.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5.0"},
      {:websockex, "~> 0.5.1"}
    ]
  end

  # defp escript do
  #   [
  #     main_module: Phazan
  #   ]
  # end
end
