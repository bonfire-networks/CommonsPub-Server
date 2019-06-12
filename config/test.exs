use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :moodle_net, MoodleNetWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
# config :logger, level: :debug

# Configure your database
config :moodle_net, MoodleNet.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "moodle_net_test",
  hostname: System.get_env("DATABASE_HOST") || "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Reduce hash rounds for testing
config :pbkdf2_elixir, rounds: 1

config :phoenix_integration,
  endpoint: MoodleNetWeb.Endpoint

config :moodle_net, MoodleNet.Mailer,
  adapter: Bamboo.TestAdapter

config :moodle_net, :ap_base_url, "http://test.localhost:4001/"
