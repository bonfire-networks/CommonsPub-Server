defmodule MoodleNet.Mixfile do
  use Mix.Project

  # General configuration of the project
  def project do
    [
      app: :moodle_net,
      version: "0.9.5-dev",
      elixir: "~> 1.9.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: releases(),
      name: "MoodleNet",
      homepage_url: "http://new.moodle.net",
      source_url: "https://gitlab.com/moodlenet/servers/federated",
      docs: [
        main: "readme", # The first page to display from the docs
        logo: "assets/static/images/moodlenet-logo.png",
        extras: ["README.md", "HACKING.md", "DEPLOY.md"] # extra pages to include
      ]
    ]
  end

  # Configuration for the OTP application.
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {MoodleNet.Application, []},
     extra_applications: [
       :logger,
       :runtime_tools,
       :comeonin,
       :hackney
     ]
    ]
  end

  defp releases do
    [
      moodle_net: [
        include_executables_for: [:unix]
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [ # graphql
      {:absinthe, "~> 1.4"},
      {:absinthe_plug, "~> 1.4"},
      # webserver
      {:cowboy, "~> 2.5"},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.7"},
      {:cors_plug, "~> 2.0"}, # security (CORS)
      # phoenix
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_integration, "~> 0.6.0"},
      {:phoenix_ecto, "~> 4.0"},
      # database
      {:ecto, "~> 3.1"},
      {:ecto_sql, "~> 3.1"},
      {:postgrex, "~> 0.14"},
      # Password hashing
      {:comeonin, "~> 4.1.1"}, 
      {:pbkdf2_elixir, "~> 0.12.3"},
      # Outbound HTTP
      {:hackney, "~> 1.15"},
      {:tesla, "~> 1.2"},
      # Email
      {:bamboo, "~> 1.2"}, # sending
      {:email_checker, "~> 0.1"}, # checking validity
      # Monitoring
      {:telemetry, "~> 0.4.0"}, # stats
      {:sentry, "~> 7.1", runtime: sentry?()}, # production only
      # Misc
      {:jason, "~> 1.1"},    # json
      {:gettext, "~> 0.17"}, # localisation
      {:recase, "~> 0.2"},   # camel/snake/kebabification
      {:furlex, git: "https://gitlab.com/moodlenet/servers/furlex"}, # webpage summary
      # dev/test only
      {:faker, "~> 0.12"}, # fake data generation. TODO: stop using outside of tests
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
    ]
  end

  defp sentry?(), do: Mix.env not in [:dev, :test]

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.seeds": ["run priv/repo/seeds.exs"],
      "sentry.recompile": ["deps.compile sentry --force", "compile"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
