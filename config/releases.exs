import Config
require Logger

fallback_env = fn a, b, c -> System.get_env(a) || System.get_env(b) || c end

config :commons_pub, CommonsPub.Repo,
  username: fallback_env.("POSTGRES_USER", "DATABASE_USER", "postgres"),
  password: fallback_env.("POSTGRES_PASSWORD", "DATABASE_PASS", "postgres"),
  database: fallback_env.("POSTGRES_DB", "DATABASE_NAME", "postgres"),
  hostname: fallback_env.("POSTGRES_HOST", "DATABASE_HOST", "localhost"),
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

mail_blackhole = fn var ->
  IO.puts(
    "WARNING: The environment variable #{var} was not set or was set incorrectly, mail will NOT be sent."
  )

  config :commons_pub, CommonsPub.Mail.MailService, adapter: Bamboo.LocalAdapter
end

mail_mailgun = fn ->
  base_uri = System.get_env("MAIL_BASE_URI", "https://api.mailgun.net/v3")

  case System.get_env("MAIL_KEY") do
    nil ->
      mail_blackhole.("MAIL_KEY")

    key ->
      case System.get_env("MAIL_DOMAIN") do
        nil ->
          mail_blackhole.("MAIL_DOMAIN")

        domain ->
          case System.get_env("MAIL_FROM") do
            nil ->
              mail_blackhole.("MAIL_FROM")

            from ->
              config :commons_pub, CommonsPub.Mail.MailService,
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
    nil ->
      mail_blackhole.("MAIL_SERVER")

    server ->
      case System.get_env("MAIL_DOMAIN") do
        nil ->
          mail_blackhole.("MAIL_DOMAIN")

        domain ->
          case System.get_env("MAIL_USER") do
            nil ->
              mail_blackhole.("MAIL_USER")

            user ->
              case System.get_env("MAIL_PASSWORD") do
                nil ->
                  mail_blackhole.("MAIL_PASSWORD")

                password ->
                  case System.get_env("MAIL_FROM") do
                    nil ->
                      mail_blackhole.("MAIL_FROM")

                    from ->
                      config :commons_pub, CommonsPub.Mail.MailService,
                        adapter: Bamboo.SMTPAdapter,
                        server: server,
                        hostname: domain,
                        port: 587,
                        username: user,
                        password: password,
                        tls: :always,
                        allowed_tls_versions: [:"tlsv1.2"],
                        ssl: false,
                        retries: 1,
                        auth: :always,
                        reply_to: from
                  end
              end
          end
      end
  end
end

case System.get_env("MAIL_BACKEND") do
  "mailgun" -> mail_mailgun.()
  "smtp" -> mail_smtp.()
  # mail_blackhole.("MAIL_BACKEND")
  _ -> mail_mailgun.()
end

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
