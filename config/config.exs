# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :moodle_net, ecto_repos: [MoodleNet.Repo]

# config :moodle_net, MoodleNet.Repo, types: MoodleNet.PostgresTypes, adapter: Ecto.Adapters.Postgres

config :moodle_net, MoodleNet.Upload,
  uploader: MoodleNet.Uploaders.Local,
  strip_exif: false

config :moodle_net, MoodleNet.Uploaders.Local,
  uploads: "uploads",
  uploads_url: "{{base_url}}/media/{{file}}"

config :moodle_net, MoodleNet.Uploaders.S3,
  bucket: nil,
  public_endpoint: "https://s3.amazonaws.com"

config :moodle_net, :emoji, shortcode_globs: ["/emoji/custom/**/*.png"]

config :moodle_net, :uri_schemes, additionnal_schemes: []

# Configures the endpoint
config :moodle_net, MoodleNetWeb.Endpoint,
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

config :moodle_net, :httpoison, MoodleNet.HTTP

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
  name: "Pub of the Commons",
  email: "example@example.local",
  description: "A Pub of the Commons instance, a generic fediverse server",
  limit: 5000,
  upload_limit: 16_000_000,
  registrations_open: true,
  rewrite_policy: ActivityPubWeb.MRF.NoOpPolicy,
  public: true,
  quarantined_instances: [],
  managed_config: true

config :moodle_net, :fe,
  theme: "moodle_net-dark",
  logo: "/static/logo.png",
  background: "/static/bg.jpg",
  redirect_root_no_login: "/registration",
  logo_mask: true,
  logo_margin: "0.1em",
  redirect_root_login: "/main/friends",
  show_instance_panel: true,
  scope_options_enabled: false,
  collapse_message_with_subject: false

config :moodle_net, :activitypub,
  accept_blocks: true,
  unfollow_blocked: true,
  outgoing_blocks: true

config :moodle_net, :user, deny_follow_blocked: true

config :moodle_net, :mrf_rejectnonpublic,
  allow_followersonly: false,
  allow_direct: false

config :moodle_net, :mrf_simple,
  media_removal: [],
  media_nsfw: [],
  federated_timeline_removal: [],
  reject: [],
  accept: []

config :moodle_net, :media_proxy,
  enabled: false,
  redirect_on_failure: true

# base_url: "https://cache.moodle_net.social"

config :phoenix, :format_encoders, json: Jason
config :phoenix, :json_library, Jason

config :moodle_net, :suggestions,
  enabled: false,
  third_party_engine:
    "http://vinayaka.distsn.org/cgi-bin/vinayaka-user-match-suggestions-api.cgi?{{host}}+{{user}}",
  timeout: 300_000,
  limit: 23,
  web: "https://vinayaka.distsn.org/?{{host}}+{{user}}"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
