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
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:ecto, "~> 3.1"},
      {:ecto_sql, "~> 3.1"},
      {:postgrex, "~> 0.14"},
      {:jason, "~> 1.1"},
      {:gettext, "~> 0.15"},
      {:cowboy, "~> 2.5"},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.7"},
      # HTTP client
      {:hackney, "~> 1.15"},
      {:comeonin, "~> 4.1.1"},
      {:pbkdf2_elixir, "~> 0.12.3"},
      {:cors_plug, "~> 2.0"},
      {:bamboo, "~> 1.2"},
      # FIXME using prod as well for the moment
      {:faker, "~> 0.11"},
      {:recase, "~> 0.2"},
      {:absinthe, "~> 1.4"},
      {:absinthe_plug, "~> 1.4"},
      {:phoenix_integration, "~> 0.6.0"},
      {:furlex, git: "https://github.com/alexcastano/furlex"},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:sentry, "~> 7.1", runtime: sentry?()},
      {:telemetry, "~> 0.4.0"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:tesla, "~> 1.2"},
      {:http_signatures,
       git: "https://git.pleroma.social/pleroma/http_signatures.git",
       ref: "293d77bb6f4a67ac8bde1428735c3b42f22cbb30"}
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
