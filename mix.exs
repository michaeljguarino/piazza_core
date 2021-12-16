defmodule PiazzaCore.MixProject do
  use Mix.Project

  @vsn "0.3.3"

  def project do
    [
      app: :piazza_core,
      version: @vsn,
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      description: description(),
      docs: [source_url: "https://github.com/michaeljguarino/piazza_core"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp description() do
    "Simple building blocks for building elixir web apps"
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.1"},
      {:ecto_enum, "~> 1.4"},
      {:gen_stage, "~> 0.14.2"},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:ex_crypto, "~> 0.10"},
      {:protobuf, "~> 0.5.3"}
    ]
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/michaeljguarino/piazza_core"}
    ]
  end
end
