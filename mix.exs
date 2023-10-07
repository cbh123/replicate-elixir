defmodule Replicate.MixProject do
  use Mix.Project

  def project do
    [
      app: :replicate,
      version: "1.1.2",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      deps: deps(),
      name: "Replicate",
      source_url: "https://github.com/replicate/replicate-elixir",
      homepage_url: "https://hexdocs.pm/replicate/readme.html",
      docs: [
        main: "readme",
        extras: ["README.md", "cheatsheet.cheatmd", "CHANGELOG.md"],
        logo: "logo.png"
      ]
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
      {:httpoison, "~> 2.0"},
      {:jason, "~> 1.2"},
      {:mox, "~> 1.0", only: :test},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "The official Elixir client for Replicate. It lets you run models from your Elixir code, and everything else you can do with Replicate's HTTP API."
  end

  defp package() do
    [
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README* CHANGELOG*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/replicate/replicate-elixir"}
    ]
  end
end
