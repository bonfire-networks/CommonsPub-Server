# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Mixfile do
  use Mix.Project

  # General configuration of the project
  def project do
    [
      app: :moodle_net,
      version: "0.9.6-dev",
      elixir: "~> 1.10.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: releases(),
      name: "MoodleNet",
      homepage_url: "http://moodle.net/",
      source_url: "https://gitlab.com/moodlenet/backend",
      docs: [
        main: "readme", # The first page to display from the docs
        logo: "assets/static/images/moodlenet-logo.png",
        extras: ["README.md", "HACKING.md", "DEPLOY.md", "MRF.md"] # extra pages to include
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test]
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
      {:absinthe, "~> 1.5"},
      {:absinthe_plug, "~> 1.5"},
      # webserver
      {:cowboy, "~> 2.6"},
      {:plug_cowboy, "~> 2.1"},
      {:plug, "~> 1.8"},
      {:cors_plug, "~> 2.0"}, # security (CORS)
      # phoenix
      {:phoenix, "~> 1.5.3"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_html, "~> 2.14"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_integration, "~> 0.8.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:floki, "~> 0.26.0", override: true},
      # File storage
      {:belt, git: "https://github.com/commonspub/belt"},
      # File format parsing
      {:twinkle_star, git: "https://github.com/commonspub/twinkle_star"},
      # database
      # {:ecto, "~> 3.3.4", override: true},
      # {:ecto_sql, "~> 3.3.4", override: true},
      {:ecto, "~> 3.4", override: true},
      {:ecto_sql, "~> 3.4", override: true},
      {:postgrex, "~> 0.14"},
      {:ecto_ulid,
       git: "https://github.com/irresponsible/ecto-ulid",
       branch: "moodlenet"},
      # crypto
      {:cloak_ecto, "~> 1.0"}, # Username reservation
      {:argon2_elixir, "~> 2.0"}, # Password hashing
      # Outbound HTTP
      {:hackney, "~> 1.15.2"},
      {:tesla, "~> 1.2"},
      # Email
      {:bamboo, "~> 1.5"}, # sending
      {:email_checker, "~> 0.1"}, # checking validity
      # Monitoring
      {:telemetry, "~> 0.4.0"}, # stats
      {:sentry, "~> 7.1", runtime: sentry?()}, # production only
      # Misc
      # {:protocol_ex, "~> 0.3.0"},
      {:jason, "~> 1.2"},    # json
      {:gettext, "~> 0.18"}, # localisation
      {:recase, "~> 0.2"},   # camel/snake/kebabification
      {:furlex, git: "https://gitlab.com/moodlenet/servers/furlex"}, # webpage summary
      {:http_signatures,
      git: "https://git.pleroma.social/pleroma/http_signatures.git",
      ref: "293d77bb6f4a67ac8bde1428735c3b42f22cbb30"}, # activity signing
      {:oban, "~> 1.2.0"}, # job queue
      {:timex, "~> 3.5"}, # timedate headers
      {:cachex, "~> 3.2"}, # caching
      # CommonsPub:
      {:geo_postgis, "~> 3.1"}, # geolocation in postgres
      # {:dlex, "~> 0.4", override: true},
      # {:castore, "~> 0.1.0", optional: true},
      # {:mint, github: "ericmj/mint", branch: "master"},
      # {:retrieval, "~> 0.9.1"}, # taxonomy trees
      # {:redix, "~> 0.10.5"}, # Redis client
      # {:ex_redi, "~> 0.1.1"}, # RediSearch client
      # {:redisgraph, "~> 0.1.0"}, # RedisGraph client
      # dev/test only
      {:dbg, "~> 1.0", only: [:dev, :test]},
      {:zest, "~> 0.1.1", only: [:dev, :test]},
      {:grumble, "~> 0.1.3", only: [:dev, :test]},
      {:faker, "~> 0.12"},                  # fake data generation for moodlenet
      {:ex_machina, "~> 2.3", only: [:dev, :test]}, # fake data generation for AP
      {:stream_data, "~> 0.5"},                     # property testing
      # {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false}, # type checking
      {:ex_doc, "~> 0.22", only: :dev, runtime: false}, # doc gen
      {:excoveralls, "~> 0.10", only: :test}, # test coverage statistics
      {:mock, "~> 0.3.3", only: :test} # module mocking
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
