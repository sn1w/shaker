defmodule Shaker.MixProject do
  use Mix.Project

  def project do
    [
      app: :shaker,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      elixirc_paths: ["lib", "shared"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :iex]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
        {:socket, "~> 0.3"},
        {:castore, "~> 0.1.0"},
        {:protobuf, "~> 0.5.3"},
        {:google_protos, "~> 0.1"},
        {:httpoison, "~> 1.6"}
    ]
  end

  defp escript do
    [main_module: Shaker]
  end
end
