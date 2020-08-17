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
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers() ++ [:protocol_ex],
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: releases(),
      name: "MoodleNet",
      homepage_url: "http://moodle.net/",
      source_url: "https://gitlab.com/moodlenet/backend",
      docs: [
        # The first page to display from the docs
        main: "readme",
        logo: "assets/static/images/logo_commonspub.png",
        # extra pages to include
        # extra pages to include
        extras: [
          "README.md",
          "docs/HACKING.md",
          "docs/DEPLOY.md",
          "docs/MRF.md",
          "docs/GRAPHQL.md",
          "docs/ARCHITECTURE.md"
        ],
        output: "docs/exdoc"
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test]
    ]
  end

  # Configuration for the OTP application.
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {MoodleNet.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :hackney,
        :mime,
        :belt,
        :cachex,
        :bamboo,
        :bamboo_smtp
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
    # graphql
    [
      {
        :absinthe,
        "~> 1.5"
        # git: "https://github.com/absinthe-graphql/absinthe", override: true,
      },
      {:absinthe_plug, "~> 1.5"},
      {:absinthe_error_payload, "~> 1.0"},
      # webserver
      {:cowboy, "~> 2.6"},
      {:plug_cowboy, "~> 2.2"},
      {:cowlib, "~> 2.9", override: true},
      {:plug, "~> 1.10"},
      # security (CORS)
      {:cors_plug, "~> 2.0"},
      # phoenix
      {:phoenix, "~> 1.5"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_html, "~> 2.14"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_integration, "~> 0.8"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_live_view, "~> 0.14"},
      {:floki, "~> 0.27", override: true},
      # File storage
      {:belt, git: "https://github.com/commonspub/belt"},
      # File format parsing
      {:twinkle_star, git: "https://github.com/commonspub/twinkle_star"},
      # database
      # {:ecto, "~> 3.3.4", override: true},
      # {:ecto_sql, "~> 3.3.4", override: true},
      {:ecto, "~> 3.4", override: true},
      {:ecto_sql, "~> 3.4", override: true},
      {:postgrex, "~> 0.15"},
      {:ecto_ulid, git: "https://github.com/irresponsible/ecto-ulid", branch: "moodlenet"},
      # crypto
      {:castore, "~> 0.1"},
      # Username reservation
      {:cloak_ecto, "~> 1.0"},
      # Password hashing
      {:argon2_elixir, "~> 2.3"},
      # Outbound HTTP
      {:hackney, "~> 1.16"},
      {:gun,
       github: "ninenines/gun", ref: "e1a69b36b180a574c0ac314ced9613fdd52312cc", override: true},
      {
        :tesla,
        git: "https://git.pleroma.social/pleroma/elixir-libraries/tesla.git",
        ref: "61b7503cef33f00834f78ddfafe0d5d9dec2270b",
        override: true
      },
      ## Email
      # sending
      {:bamboo, "~> 1.5"},
      # generic smtp backend
      {:bamboo_smtp, "~> 2.1.0"},
      # checking validity
      {:email_checker, "~> 0.1"},
      # Monitoring
      # stats
      {:telemetry, "~> 0.4.0"},
      # production only
      {:sentry, "~> 7.1", runtime: sentry?()},
      # Misc
      {:protocol_ex, "~> 0.4.3"},
      # json
      {:jason, "~> 1.2"},
      # localisation
      {:gettext, "~> 0.18"},
      # camel/snake/kebabification
      {:recase, "~> 0.5"},
      # webpage info extraction
      {:furlex,
       git: "https://gitlab.com/moodlenet/servers/furlex",
       ref: "589c6a2e15e97606c53f86b466087192de3680fa"},
      # html parser
      # {:fast_html, "~> 1.0"},
      {:html5ever, "~> 0.8"},
      # activitypub signing
      {
        :http_signatures,
        git: "https://git.pleroma.social/pleroma/elixir-libraries/http_signatures"
      },
      # job queue
      {:oban, "~> 1.2.0"},
      # timedate headers
      {:timex, "~> 3.5"},
      # caching
      {:cachex, "~> 3.2"},
      # CommonsPub:
      # process HTML content
      {:html_sanitize_ex, "~> 1.4"},
      {
        :linkify,
        git: "https://gitlab.com/CommonsPub/linkify.git",
        ref: "9360ed495ec04ab0f9f254670484f01dea668d38"
        # path: "uploads/linkify"
        # "~> 0.2.0"
      },
      # geolocation in postgres
      {:geo_postgis, "~> 3.1"},
      # geocoding
      {:geocoder, "~> 1.0"},
      {:earmark, "~> 1.4"},
      {:slugger, "~> 0.3"},
      # {:pointers, "~> 0.2.2"},
      {
        :pointers,
        # git: "https://github.com/commonspub/pointers.git",
        # ref: "b0cbc4b1a2f83b870f24436dd5968fec428c6530"
        path: "uploads/pointers-main"
        # git: "https://github.com/mayel/pointers.git",
        # ref: "01751caa54b15c4928eb8389bd7635aa0bd20584"
        # path: "uploads/pointers"
      },
      # {:pointers_ulid, path: "uploads/pointers_ulid", override: true},
      # {:dlex, "~> 0.4", override: true},
      # {:castore, "~> 0.1.0", optional: true},
      # {:mint, github: "ericmj/mint", branch: "master"},
      # {:retrieval, "~> 0.9.1"}, # taxonomy trees
      # {:redix, "~> 0.10.5"}, # Redis client
      # {:ex_redi, "~> 0.1.1"}, # RediSearch client
      # {:redisgraph, "~> 0.1.0"}, # RedisGraph client
      # dev/test only
      {:dbg, "~> 1.0", only: [:dev, :test]},
      {:grumble, "~> 0.1.3", only: [:dev, :test]},
      # fake app data generation, also used in prototype API endponts
      {:faker, "~> 0.12"},
      # required by CommonsPub.Utils.Simulation
      {:zest, "~> 0.1.1", only: [:dev, :test]},
      # fake data generation for AP
      {:ex_machina, "~> 2.3", only: [:dev, :test]},
      # property testing
      {:stream_data, "~> 0.5"},
      # {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false}, # type checking
      # doc gen
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      # test coverage statistics
      {:excoveralls, "~> 0.10", only: :test},
      # module mocking
      {:mock, "~> 0.3.3", only: :test}
    ]
  end

  defp sentry?(), do: Mix.env() not in [:dev, :test]

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
