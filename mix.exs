defmodule Ht16k33Multi.MixProject do
  use Mix.Project

  def project do
    [
      app: :ht16k33Multi,
      version: "0.1.0",
      description:
        "A library for controlling one or more Ht16k33 microchips, which are commonly used to drive 7-segment displays.",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # ExDocs
      name: "Ht16k33Multi",
      source_url: "https://github.com/alexisruccius/ht16k33_multi",
      homepage_url: "https://github.com/alexisruccius/ht16k33_multi",
      docs: &docs/0
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:circuits_i2c, "~> 2.0"},
      {:circuits_sim, "~> 0.1.1"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  # ExDocs
  defp docs do
    [
      # The main page in the docs
      main: "Ht16k33Multi",
      logo: "assets/ht16k33multi-logo.jpg",
      extras: ["README.md"]
    ]
  end
end
