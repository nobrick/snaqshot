defmodule Snaqshot.Mixfile do
  use Mix.Project

  def project do
    [app: :snaqshot,
     version: "0.0.1",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :calendar, :poison, :httpoison, :quantum],
     mod: {Snaqshot, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:calendar, "~> 0.14.0"},
     {:poison, "~> 2.0"},
     {:httpoison, "~> 0.8.0"},
     {:quantum, ">= 1.7.1"},
     {:distillery, git: "https://github.com/bitwalker/distillery.git"}]
  end
end
