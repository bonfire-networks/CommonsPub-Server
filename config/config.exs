# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :moodle_net, ecto_repos: [MoodleNet.Repo]

# Configures the endpoint
config :moodle_net, MoodleNetWeb.Endpoint,
  instrumenters: [Appsignal.Phoenix.Instrumenter],
  url: [host: "localhost"],
  protocol: "https",
  secret_key_base: "aK4Abxf29xU9TTDKre9coZPUgevcVCFQJe/5xP/7Lt4BEif6idBIbjupVbOrbKxl",
  render_errors: [view: MoodleNetWeb.ErrorView, accepts: ["json", "activity+json"]],
  pubsub: [name: MoodleNet.PubSub, adapter: Phoenix.PubSub.PG2],
  secure_cookie_flag: true

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :mime, :types, %{
  "application/activity+json" => ["json"],
  "application/ld+json" => ["json"]
}

config :moodle_net, MoodleNet.Mailer,
  adapter: Bamboo.MailgunAdapter, # replace this with the email deliver service adapter you want to use: https://github.com/thoughtbot/bamboo#available-adapters
  api_key: System.get_env("MAIL_KEY"), # use API key from runtime environment variable (make sure to set it on the server or CI config), and fallback to build-time env variable
  domain: System.get_env("MAIL_DOMAIN"), # use sending domain from runtime env, and fallback to build-time env variable
  open_email_in_browser_url: "http://localhost:4000/sent_emails" # optional

version =
  with {version, 0} <- System.cmd("git", ["rev-parse", "HEAD"]) do
    "MoodleNet #{Mix.Project.config()[:version]} #{String.trim(version)}"
  else
    _ -> "MoodleNet #{Mix.Project.config()[:version]} dev"
  end

# Configures http settings, upstream proxy etc.
config :moodle_net, :http, proxy_url: nil

config :moodle_net, :instance,
  version: version,
  name: "MoodleNet",
  email: "moodlenet-moderators@moodle.com",
  description: "An instance of MoodleNet, a federated server for educators"

config :phoenix, :format_encoders, json: Jason
config :phoenix, :json_library, Jason

config :furlex, Furlex.Oembed,
  oembed_host: "https://oembed.com"

config :moodle_net, MoodleNetWeb.Gettext, default_locale: "en", locales: ~w(en es)

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :phoenix, :template_engines,
  eex: Appsignal.Phoenix.Template.EExEngine,
  exs: Appsignal.Phoenix.Template.ExsEngine
