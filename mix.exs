defmodule Scribex.MixProject do
  use Mix.Project

  def project do
    [
      app: :scribex,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:aws, "~> 0.11.0"},
      {:hackney, "~> 1.18"},
      {:witchcraft, "~> 1.0"},
      {:tentacat, "~> 2.2"},
      {:git_cli, "~> 0.3.0"}
    ]
  end
end
