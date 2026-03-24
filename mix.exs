defmodule HelmsmanBrowseTool.MixProject do
  use Mix.Project

  @version "0.2.0"
  @source_url "https://github.com/pepicrft/helmsman_browse_tool"

  def project do
    [
      app: :helmsman_browse_tool,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      name: "HelmsmanBrowseTool",
      description: "A Helmsman tool for web browsing via Browse",
      source_url: @source_url,
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:helmsman, "~> 0.4"},
      {:browse, "~> 0.2"},
      {:quokka, "~> 2.12", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.35", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:mimic, "~> 1.11", only: :test}
    ]
  end

  defp docs do
    [
      main: "HelmsmanBrowseTool",
      extras: ["README.md"],
      source_ref: @version,
      source_url: @source_url
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      },
      files: ~w(lib .formatter.exs mix.exs README.md CHANGELOG.md LICENSE)
    ]
  end

  defp aliases do
    [
      lint: ["format --check-formatted", "credo --strict", "dialyzer"]
    ]
  end
end
