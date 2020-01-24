import Config
require Logger

config :moodle_net, MoodleNet.Repo,
  username: System.fetch_env!("DATABASE_USER"),
  password: System.fetch_env!("DATABASE_PASS"),
  database: System.fetch_env!("DATABASE_NAME"),
  hostname: System.get_env("DATABASE_HOST", "localhost"),
  pool_size: 15

hostname = System.fetch_env!("HOSTNAME")
desc = System.fetch_env("INSTANCE_DESCRIPTION")
port = String.to_integer(System.get_env("PORT", "4000"))
base_url = System.get_env("BASE_URL", "https://" <> System.fetch_env!("HOSTNAME"))

config :moodle_net, Instance,
  hostname: hostname,
  description: desc

config :moodle_net, MoodleNetWeb.Endpoint,
  http: [port: port],
  url: [host: hostname, port: port],
  root: ".",
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE")

config :moodle_net,
  base_url: base_url,
  ap_base_path: System.get_env("AP_BASE_PATH", "/pub"), # env variable to customise the ActivityPub URL prefix (needs to be changed at compile time)
  frontend_base_url: System.get_env("FRONTEND_BASE_URL", base_url) # env variable for URL of frontend, otherwise assume proxied behind same host as backend

upload_dir = System.get_env("UPLOAD_DIR", "/var/www/uploads")
upload_url = System.get_env("UPLOAD_URL", base_url <> "/uploads/")

config :moodle_net, MoodleNet.Uploads.Storage,
  provider: [Belt.Provider.Filesystem, [[directory: upload_dir, base_url: upload_url]]]

mail_base_uri = System.get_env("MAIL_BASE_URI", "https://api.mailgun.net/v3")
mail_domain = System.get_env("MAIL_DOMAIN")
mail_key = System.get_env("MAIL_KEY")

if not is_nil(mail_key) do
  config :moodle_net, MoodleNet.Mail.MailService,
    adapter: Bamboo.MailgunAdapter,
    domain: mail_domain,
    api_key: mail_key,
    base_uri: mail_base_uri
end

sentry_dsn = System.get_env("SENTRY_DSN")
sentry_env = System.get_env("SENTRY_ENV")

Application.ensure_all_started(:logger, :permanent)

if is_binary(sentry_dsn) and is_binary(sentry_env) do
  Logger.info("[Release Config] Configuring sentry with SENTRY_DSN: #{sentry_dsn} SENTRY_ENV: #{sentry_env}")
  config :sentry,
    dsn: sentry_dsn,
    environment_name: sentry_env,
    root_source_code_path: File.cwd!,
    enable_source_code_context: true,
    included_environments: [sentry_env]
else
  Logger.info("[Release Config] Not configuring sentry as at least one of SENTRY_DSN, SENTRY_ENV is missing")
end
