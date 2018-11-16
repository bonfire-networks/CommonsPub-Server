defmodule MoodleNet.Mixfile do
  use Mix.Project

  def project do
    [
      app: :moodle_net,
      version: "0.9.0",
      elixir: "~> 1.7.3",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {MoodleNet.Application, []}, extra_applications: [:logger, :runtime_tools, :comeonin]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.2-rc", only: :dev},
      {:ecto, "~> 3.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, "~> 0.14"},
      {:jason, "~> 1.0"},
      {:gettext, "~> 0.15"},
      {:cowboy, "~> 2.5"},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.7"},
      {:comeonin, "~> 4.1.1"},
      {:pbkdf2_elixir, "~> 0.12.3"},
      {:trailing_format_plug, "~> 0.0.7"},
      {:html_sanitize_ex, "~> 1.3.0"},
      {:calendar, "~> 0.17.4"},
      {:cachex, "~> 3.0.2"},
      {:httpoison, "~> 1.2.0"},
      {:mogrify, "~> 0.6.1"},
      {:ex_aws, "~> 2.0"},
      {:ex_aws_s3, "~> 2.0"},
      {:faker, "~> 0.11", only: [:dev, :test]},
      # {:ex_machina, "~> 2.2", only: :test},
      {:ex_machina, git: "https://github.com/thoughtbot/ex_machina", ref: "master", only: :test},
      {:phoenix_integration, git: "https://github.com/alexcastano/phoenix_integration", only: :test},
      {:credo, "~> 0.9.3", only: [:dev, :test]},
      {:mock, "~> 0.3.1", only: :test},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:absinthe, "~> 1.4"},
      {:absinthe_plug, "~> 1.4"},
      {:crypt,
       git: "https://github.com/msantos/crypt", ref: "1f2b58927ab57e72910191a7ebaeff984382a1d3"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
