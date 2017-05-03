defmodule Kronos.Mixfile do
  use Mix.Project

  def project do
    [
      app: :kronos,
      version: "1.0.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      name: "Kronos",
      source_url: "https://github.com/xvw/kronos",
      homepage_url: "https://github.com/xvw/kronos/doc",
      deps: deps(),
      package: package(),
      description: description(),
      docs: docs()
    ]
  end

  defp description do 
    """
    Kronos is a library to facilitate simple arithmetic operations between timestamps.
    This library is based on Mizur to type values.
    """
  end

  defp package do
    [
     name: :kronos,
     files: ["lib", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Xavier Van de Woestyne"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/xvw/kronos",
              "Docs" => "http://xvw.github.io/kronos/doc/readme.html"}]
end

  # configuration of the documentation 
  def docs do 
    [
      main: "readme",
      extras: [
        "README.md"
      ]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:mizur, "~> 1.0.1"},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end
end
