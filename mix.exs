# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Mixfile do
  use Mix.Project

  # General configuration of the project
  def project do
    [
      app: :moodle_net,
      version: "0.9.6-dev",
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
        extras: ["README.md", "HACKING.md", "DEPLOY.md", "MRF.md"] # extra pages to include
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
       :hackney,
       :mime,
       :belt,
       :cachex,
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
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [ # graphql
      {:absinthe, git: "https://github.com/absinthe-graphql/absinthe", override: true},
      {:absinthe_plug, git: "https://github.com/absinthe-graphql/absinthe_plug"},
      # webserver
      {:cowboy, "~> 2.6"},
      # {:cowboy, "~> 2.5.0"},
      # {:cowlib, "~> 2.6.0"},
      {:plug_cowboy, "~> 2.1"},
      {:plug, "~> 1.8"},
      {:cors_plug, "~> 2.0"}, # security (CORS)
      # phoenix
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_html, "~> 2.13"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_integration, "~> 0.6.0"},
      {:phoenix_ecto, "~> 4.0"},
      # File storage
      {:belt, git: "https://gitlab.com/kalouantonis/belt"},
      # File format parsing
      {:format_parser, git: "https://github.com/antoniskalou/format_parser.ex"},
      {:twinkle_star, git: "https://github.com/antoniskalou/twinkle_star"},
      # database
      {:ecto, "~> 3.1"},
      {:ecto_sql, "~> 3.1"},
      {:postgrex, "~> 0.14"},
      {:ecto_ulid,
       git: "https://github.com/irresponsible/ecto-ulid",
       branch: "moodlenet"},
      # Password hashing
      {:argon2_elixir, "~> 2.0"},
      # Outbound HTTP
      {:hackney, "~> 1.15.2"},
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
      {:http_signatures,
      git: "https://git.pleroma.social/pleroma/http_signatures.git",
      ref: "293d77bb6f4a67ac8bde1428735c3b42f22cbb30"}, # activity signing
      {:oban, "~> 0.11"}, # job queue
      {:timex, "~> 3.5"}, # timedate headers
      {:cachex, "~> 3.2"}, # caching
      # {:dlex, "~> 0.4", override: true},
      # {:castore, "~> 0.1.0", optional: true},
      # {:mint, github: "ericmj/mint", branch: "master"},
      # {:retrieval, "~> 0.9.1"}, # taxonomy trees
      # dev/test only
      {:faker, "~> 0.12"},                  # fake data generation for moodlenet
      {:ex_machina, "~> 2.3", only: [:dev, :test]}, # fake data generation for AP
      {:stream_data, "~> 0.4"},             # property testing
      #{:redix, "~> 0.10.5"}, # Redis client
      #{:ex_redi, "~> 0.1.1"}, # RediSearch client
      {:redisgraph, "~> 0.1.0"}, # RedisGraph client
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false}, # type checking
      {:ex_doc, "~> 0.21", only: :dev, runtime: false} # doc gen
    ]
  end

  defp sentry?(), do: Mix.env not in [:dev, :test]

  defp aliases do
    [
      "ecto.rebuild": ["ecto.reset", "ecto.seeds"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.seeds": ["run priv/repo/seeds.exs"],
      "sentry.recompile": ["deps.compile sentry --force", "compile"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
