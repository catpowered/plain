defmodule Plain.MixProject do
  use Mix.Project

  @source_url "https://github.com/CatPowered/plain"
  @description "SDK for the Plain.com GraphQL API"

  def project do
    [
      app: :plain,
      description: @description,
      version: "0.2.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp deps do
    [
      {:req, "~> 0.4.0"},
      {:jason, "~> 1.2"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      maintainers: ["Harry Bairstow"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: [
        "lib",
        "mutations",
        "queries",
        ".formatter.exs",
        "mix.exs",
        "README*",
        "LICENSE*"
      ]
    ]
  end
end
