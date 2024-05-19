defmodule Plain.MixProject do
  use Mix.Project

  @source_url "https://github.com/CatPowered/plain"

  def project do
    [
      app: :plain,
      version: "0.1.0",
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
      {:jason, "~> 1.2"}
    ]
  end

  defp package() do
    [
      maintainers: ["Harry Bairstow"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end
end
