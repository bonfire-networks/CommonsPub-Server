# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
import Config
# We don't run a server during test. If one is required,
# you can enable the server option below.
config :moodle_net, MoodleNetWeb.Endpoint,
  http: [port: 4001],
  server: true

# Logging

config :logger, level: :warn
# config :logger, level: :debug
# config :moodle_net, MoodleNet.Repo, log: false

# Configure your database
config :moodle_net, MoodleNet.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("POSTGRES_USER", "postgres"),
  password: System.get_env("POSTGRES_PASSWORD", "postgres"),
  database: "commonspub_test",
  hostname: System.get_env("DATABASE_HOST", "localhost"),
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 25

# Reduce cost of hashing for testing
config :argon2_elixir,
  t_cost: 1,
  m_cost: 8

config :phoenix_integration,
  endpoint: MoodleNetWeb.Endpoint

config :moodle_net, MoodleNet.Mail.MailService, adapter: Bamboo.TestAdapter

config :moodle_net,
  base_url: "http://localhost:4001",
  ap_base_path: "/pub",
  frontend_base_url: "http://localhost:4001"

config :tesla, adapter: Tesla.Mock

config :moodle_net, MoodleNet.Mail.Checker, mx: false

config :moodle_net, MoodleNet.OAuth,
  client_name: "CommonsPub",
  client_id: "CommonsPUB",
  redirect_uri: "https://commonspub.dev.local/",
  website: "https://commonspub.dev.local/",
  scopes: "read,write,follow"

# Do not federate activities during tests
config :moodle_net, :instance, federating: false

# , prune: :disabled
config :moodle_net, Oban, queues: false

config :moodle_net, MoodleNet.Uploads,
  directory: File.cwd!() <> "/test_uploads",
  path: "/uploads",
  uploads_base_url: "http://localhost:4001/uploads/"
