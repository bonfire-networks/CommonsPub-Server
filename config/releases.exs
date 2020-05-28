import Config
require Logger

config :moodle_net, MoodleNet.Repo,
  username: System.get_env("POSTGRES_USER", System.get_env("DATABASE_USER", "postgres")),
  password: System.get_env("POSTGRES_PASSWORD", System.get_env("DATABASE_PASS", "postgres")),
  database: System.get_env("POSTGRES_DB", System.get_env("DATABASE_NAME", "postgres")),
  hostname: System.get_env("DATABASE_HOST", "localhost"),
  pool_size: 15

hostname = System.fetch_env!("HOSTNAME")
desc = System.fetch_env("INSTANCE_DESCRIPTION")
port = String.to_integer(System.get_env("PORT", "4000"))
base_url = System.get_env("BASE_URL", "https://" <> System.fetch_env!("HOSTNAME"))
app_name = System.get_env("APP_NAME", "MoodleNet")

config :moodle_net, MoodleNet.Instance,
  hostname: hostname,
  description: desc

config :moodle_net, MoodleNetWeb.Endpoint,
  http: [port: port],
  url: [host: hostname, port: port],
  root: ".",
  secret_key_base: System.fetch_env!("SECRET_KEY_BASE")

config :moodle_net,
  base_url: base_url,
  app_name: app_name,
  ap_base_path: System.get_env("AP_BASE_PATH", "/pub"), # env variable to customise the ActivityPub URL prefix (needs to be changed at compile time)
  frontend_base_url: System.get_env("FRONTEND_BASE_URL", base_url) # env variable for URL of frontend, otherwise assume proxied behind same host as backend

config :moodle_net, MoodleNet.Users,
  public_registration: !System.get_env("INVITE_ONLY", "true") # enable signups?

upload_dir = System.get_env("UPLOAD_DIR", "/var/www/uploads")
upload_path = System.get_env("UPLOAD_PATH", "/uploads")
upload_url = System.get_env("UPLOAD_URL", base_url <> upload_path <> "/")

config :moodle_net, MoodleNet.Uploads,
  directory: upload_dir,
  path: upload_path,
  base_url: upload_url

mail_blackhole = fn(var) ->
  IO.puts("WARNING: The environment variable #{var} was not set or was set incorrectly, mail will NOT be sent.")
end

mail_mailgun = fn ->
  base_uri = System.get_env("MAIL_BASE_URI", "https://api.mailgun.net/v3")
  case System.get_env("MAIL_KEY") do
    nil -> mail_blackhole.("MAIL_KEY")
    key ->
      case System.get_env("MAIL_DOMAIN") do
        nil -> mail_blackhole.("MAIL_DOMAIN")
        domain ->
          case System.get_env("MAIL_FROM") do
            nil -> mail_blackhole.("MAIL_FROM")
            from ->
              config :moodle_net, MoodleNet.Mail.MailService,
                adapter: Bamboo.MailgunAdapter,
                api_key: key,
                base_uri: base_uri,
                domain: domain,
                reply_to: from
          end
      end
  end
end

mail_smtp = fn ->
  case System.get_env("MAIL_SERVER") do
    nil -> blackhole.("MAIL_SERVER")
    server ->
      case System.get_env("MAIL_DOMAIN") do
        nil -> mail_blackhole.("MAIL_DOMAIN")
        domain ->
          case System.get_env("MAIL_USER") do
            nil -> mail_blackhole.("MAIL_USER") 
            user ->
              case System.get_env("MAIL_PASSWORD") do
                nil -> mail_blackhole.("MAIL_PASSWORD") 
                password ->
                  case System.get_env("MAIL_FROM") do
                    nil -> mail_blackhole.("MAIL_FROM")
                    _ ->
                     config :moodle_net, MoodleNet.Mail.MailService,
                       adapter: Bamboo.SMTPAdapter,
                       server: server,
                       hostname: domain,
                       port: 1025,
                       username: username,
                       password: password,
                       tls: :always,
                       allowed_tls_versions: [:"tlsv1.2"],
                       ssl: false,
                       retries: 1,
                       auth: :always
                  end
              end
          end
      end
  end
end
case System.get_env("MAIL_BACKEND") do
  "mailgun" -> mail_mailgun.()
  "smtp" -> mail_smtp.()
  _ -> mail_blackhole.()
end

## Sentry

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
