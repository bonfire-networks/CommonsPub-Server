use Mix.Config

defp env(name) do
  case System.get_env(name) do
    nil -> throw {:missing_env_var, name}
    other -> other
  end
end

config :moodle_net, MoodleNet.Repo,
  username: env("DATABASE_USER"),
  password: env("DATABASE_PASS"),
  database: env("DATABASE_NAME"),
  hostname: env("DATABASE_HOST"),
  pool_size: 15

port = String.to_integer(env("PORT") || "8080")
config :moodle_net, MoodleNetWeb.Endpoint,
  http: [port: port],
  url: [host: env("HOSTNAME"), port: port],
  root: ".",
  secret_key_base: env("SECRET_KEY_BASE")

config :moodle_net, :ap_base_url, env("AP_BASE_URL")

config :moodle_net, :mail_domain, env("MAIL_DOMAIN")
config :moodle_net, :mail_key, env("MAIL_KEY")
