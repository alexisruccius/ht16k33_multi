defmodule Ht16k33Multi.MixProject do
  use Mix.Project

  def project do
    [
      app: :ht16k33_multi,
      version: "0.2.2",
      description:
        "A library for controlling one or more Ht16k33 microchips, which are commonly used to drive 7-segment displays.",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [
        ignore_modules: [
          Ht16k33Multi.CircuitSimMock.Ht16k33Mock,
          CircuitsSim.I2C.SimpleI2CDevice.Ht16k33Multi.CircuitSimMock.Ht16k33Mock
        ]
      ],

      # ExDocs
      source_url: "https://github.com/alexisruccius/ht16k33_multi",
      homepage_url: "https://github.com/alexisruccius/ht16k33_multi",
      docs: docs(),
      # Hex
      package: package()
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
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  # ExDocs
  defp docs do
    [
      # The main page in the docs
      main: "Ht16k33Multi",
      logo: "assets/ht16k33multi-logo.jpg",
      extras: ["README.md", "CHANGELOG.md"]
    ]
  end

  # Hex package
  defp package do
    [
      maintainers: ["Alexis Ruccius"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/alexisruccius/ht16k33_multi"},
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE CHANGELOG.md)
    ]
  end
end
