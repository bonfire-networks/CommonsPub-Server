import Config
require Logger

fallback_env = fn a, b, c -> System.get_env(a) || System.get_env(b) || c end

config :commons_pub, CommonsPub.Repo,
  username: fallback_env.("POSTGRES_USER", "DATABASE_USER", "postgres"),
  password: fallback_env.("POSTGRES_PASSWORD", "DATABASE_PASS", "postgres"),
  database: fallback_env.("POSTGRES_DB", "DATABASE_NAME", "commonspub_rel"),
  hostname: fallback_env.("DATABASE_HOST", "POSTGRES_HOST", "localhost"),
  pool_size: 15

hostname = System.fetch_env!("HOSTNAME")
desc = System.get_env("INSTANCE_DESCRIPTION")
port = String.to_integer(fallback_env.("HTTP_PORT", "PORT", "4000"))
base_url = System.get_env("BASE_URL", "https://" <> hostname)

config :commons_pub, CommonsPub.Instance,
  hostname: hostname,
  description: desc

config :commons_pub, CommonsPub.Web.Endpoint,
  http: [port: port],
  url: [host: hostname, port: port],
  root: ".",
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE")

config :commons_pub,
  base_url: base_url,
  # env variable to customise the ActivityPub URL prefix (needs to be changed at compile time)
  ap_base_path: System.get_env("AP_BASE_PATH", "/pub"),
  # env variable for URL of frontend, otherwise assume proxied behind same host as backend
  frontend_base_url: System.get_env("FRONTEND_BASE_URL", base_url),
  app_name: System.get_env("APP_NAME", "CommonsPub")

config :commons_pub, CommonsPub.Users,
  # enable signups?
  public_registration: !System.get_env("INVITE_ONLY", "true")

upload_dir = System.get_env("UPLOAD_DIR", "/var/www/uploads")
upload_path = System.get_env("UPLOAD_PATH", "/uploads")
upload_url = System.get_env("UPLOAD_URL", base_url <> upload_path <> "/")

config :commons_pub, CommonsPub.Uploads,
  directory: upload_dir,
  path: upload_path,
  base_url: upload_url,
  max_file_size: System.get_env("UPLOAD_LIMIT", "20000000")

## Sentry
sentry_dsn = System.get_env("SENTRY_DSN")
sentry_env = System.get_env("SENTRY_ENV")

Application.ensure_all_started(:logger, :permanent)

if is_binary(sentry_dsn) and is_binary(sentry_env) do
  Logger.info(
    "[Release Config] Configuring sentry with SENTRY_DSN: #{sentry_dsn} SENTRY_ENV: #{sentry_env}"
  )

  config :sentry,
    dsn: sentry_dsn,
    environment_name: sentry_env,
    root_source_code_path: File.cwd!(),
    enable_source_code_context: true,
    included_environments: [sentry_env]
else
  Logger.info(
    "[Release Config] Not configuring sentry as at least one of SENTRY_DSN, SENTRY_ENV is missing"
  )
end
