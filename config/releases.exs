import Config

config :moodle_net, MoodleNet.Repo,
  username: System.fetch_env!("DATABASE_USER"),
  password: System.fetch_env!("DATABASE_PASS"),
  database: System.fetch_env!("DATABASE_NAME"),
  hostname: System.fetch_env!("DATABASE_HOST"),
  pool_size: 15

port = String.to_integer(System.get_env("PORT") || "8080")

config :moodle_net, MoodleNetWeb.Endpoint,
  http: [port: port],
  url: [host: System.fetch_env!("HOSTNAME"), port: port],
  root: ".",
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE")

config :moodle_net,
  ap_base_url: System.fetch_env!("AP_BASE_URL"),
  frontend_base_url: System.fetch_env!("FRONTEND_BASE_URL")

config :moodle_net, MoodleNet.Mailer,
  domain: System.fetch_env!("MAIL_DOMAIN"),
  api_key: System.fetch_env!("MAIL_KEY")

sentry_dsn = System.get_env("SENTRY_DSN")
sentry_env = System.get_env("SENTRY_ENV")
if not is_nil(sentry_dsn) do
  config :sentry,
    dsn: sentry_dsn,
    environment_name: sentry_env || Mix.env,
    root_source_code_path: File.cwd!,
    enable_source_code_context: true
end
