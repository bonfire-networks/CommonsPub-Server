# SPDX-License-Identifier: AGPL-3.0-only
import Config

alias CommonsPub.{
  Blocks,
  Collections,
  Communities,
  Features,
  Feeds,
  Flags,
  Follows,
  Instance,
  Likes,
  Resources,
  Threads,
  Users,
  Uploads
}

alias CommonsPub.Blocks.Block
alias CommonsPub.Collections.Collection
alias CommonsPub.Communities.Community
alias CommonsPub.Feeds.{FeedActivities, FeedSubscriptions}
alias CommonsPub.Flags.Flag
alias CommonsPub.Likes.Like
alias CommonsPub.Resources.Resource
alias CommonsPub.Threads.{Comment, Thread}
alias CommonsPub.Users.User
alias CommonsPub.Workers.GarbageCollector

alias Measurement.Unit.Units
alias CommonsPub.Tag.Taggable

hostname = System.get_env("HOSTNAME", "localhost")

# LiveView support: https://hexdocs.pm/phoenix_live_view/installation.html
config :commons_pub, CommonsPub.Web.Endpoint,
  live_view: [
    signing_salt: "SECRET_SALT"
  ]

# stuff you might need to change to be viable

config :commons_pub, :app_name, System.get_env("APP_NAME", "CommonsPub")

config :commons_pub, CommonsPub.Web.Gettext, default_locale: "en", locales: ~w(en es)

# stuff you might want to change for your use case

config :commons_pub, GarbageCollector,
  # Contexts which require a mark phase, in execution order
  mark: [Uploads],
  # Contexts which need to perform maintainance, in execution order
  sweep: [
    Uploads,
    FeedActivities,
    FeedSubscriptions,
    Feeds,
    Features,
    Resources,
    Collections,
    Communities,
    Users,
    CommonsPub.Characters
  ],
  # We will not sweep content newer than this
  # one week
  grace: 302_400

contexts_agents = [
  User,
  Organisation
]

contexts_characters = [
  User,
  Collection,
  Community,
  Geolocation,
  Organisation,
  CommonsPub.Tag.Category
]

contexts_all =
  contexts_characters ++
    [
      Thread,
      Comment,
      Resource,
      Like,
      ValueFlows.Planning.Intent
    ]

desc = System.get_env("INSTANCE_DESCRIPTION", "Local development instance")

config :commons_pub, Instance,
  hostname: hostname,
  description: desc,
  # what to show or exclude in Instance Timeline
  default_outbox_query_contexts: List.delete(contexts_all, Like)

config :commons_pub, Users,
  public_registration: false,
  default_outbox_query_contexts: contexts_all,
  default_inbox_query_contexts: contexts_all

config :commons_pub, Communities,
  valid_contexts: contexts_characters,
  default_outbox_query_contexts: contexts_all,
  default_inbox_query_contexts: contexts_all

config :commons_pub, Collections,
  valid_contexts: contexts_characters,
  default_outbox_query_contexts: contexts_all,
  default_inbox_query_contexts: contexts_all

config :commons_pub, Organisation, valid_contexts: contexts_characters

config :commons_pub, CommonsPub.Characters,
  valid_contexts: contexts_characters,
  default_outbox_query_contexts: contexts_all

config :commons_pub, Feeds,
  valid_contexts: contexts_characters,
  default_query_contexts: contexts_all

config :commons_pub, Blocks, valid_contexts: contexts_characters

config :commons_pub, Follows, valid_contexts: contexts_characters

config :commons_pub, Features, valid_contexts: contexts_all

config :commons_pub, Flags, valid_contexts: contexts_all

config :commons_pub, Likes, valid_contexts: contexts_all

config :commons_pub, Threads, valid_contexts: [ValueFlows.Proposal] ++ contexts_all

config :commons_pub, Resources, valid_contexts: contexts_all

config :commons_pub, Units, valid_contexts: contexts_all

config :commons_pub, ValueFlows.Proposal.Proposals, valid_agent_contexts: contexts_agents

image_media_types = ~w(image/png image/jpeg image/svg+xml image/gif)

config :commons_pub, Uploads.ResourceUploader,
  # App formats
  # Docs
  # Images
  # Audio
  # Video
  allowed_media_types:
    ~w(text/plain text/html text/markdown text/rtf text/csv) ++
      ~w(application/rtf application/pdf application/zip application/gzip) ++
      ~w(application/x-bittorrent application/x-tex) ++
      ~w(application/epub+zip application/vnd.amazon.mobi8-ebook) ++
      ~w(application/postscript application/msword) ++
      ~w(application/powerpoint application/mspowerpoint application/vnd.ms-powerpoint application/x-mspowerpoint) ++
      ~w(application/excel application/x-excel application/vnd.ms-excel) ++
      ~w(application/vnd.oasis.opendocument.chart application/vnd.oasis.opendocument.formula) ++
      ~w(application/vnd.oasis.opendocument.graphics application/vnd.oasis.opendocument.image) ++
      ~w(application/vnd.oasis.opendocument.presentation application/vnd.oasis.opendocument.spreadsheet) ++
      ~w(application/vnd.oasis.opendocument.text) ++
      image_media_types ++
      ~w(audio/mp3 audio/m4a audio/wav audio/flac audio/ogg) ++
      ~w(video/avi video/webm video/mp4)

config :commons_pub, Uploads.IconUploader, allowed_media_types: image_media_types

config :commons_pub, Uploads.ImageUploader, allowed_media_types: image_media_types

config :commons_pub, Uploads,
  # default to 20mb
  max_file_size: "20000000"

# before compilation, replace this with the email deliver service adapter you want to use: https://github.com/thoughtbot/bamboo#available-adapters
# api_key: System.get_env("MAIL_KEY"), # use API key from runtime environment variable (make sure to set it on the server or CI config), and fallback to build-time env variable
# domain: System.get_env("MAIL_DOMAIN"), # use sending domain from runtime env, and fallback to build-time env variable
# config :commons_pub, CommonsPub.Mail.MailService,
#   adapter: Bamboo.MailgunAdapter

config :commons_pub, :mrf_simple,
  media_removal: [],
  media_nsfw: [],
  report_removal: [],
  accept: [],
  avatar_removal: [],
  banner_removal: []

config :commons_pub, Oban,
  repo: CommonsPub.Repo,
  # prune: {:maxlen, 100_000},
  poll_interval: 5_000,
  queues: [
    federator_incoming: 50,
    federator_outgoing: 50,
    ap_incoming: 10,
    mn_ap_publish: 30
  ]

config :commons_pub, :workers,
  retries: [
    federator_incoming: 5,
    federator_outgoing: 5
  ]

config :commons_pub, CommonsPub.MediaProxy,
  impl: CommonsPub.DirectHTTPMediaProxy,
  path: "/media/"

### Standin data for values you'll have to provide in the ENV in prod

config :commons_pub, CommonsPub.Web.Endpoint,
  url: [host: "localhost"],
  protocol: "https",
  secret_key_base: "aK4Abxf29xU9TTDKre9coZPUgevcVCFQJe/5xP/7Lt4BEif6idBIbjupVbOrbKxl",
  render_errors: [view: CommonsPub.Web.ErrorView, accepts: ["json", "activity+json"]],
  pubsub_server: CommonsPub.PubSub,
  secure_cookie_flag: true

version =
  with {version, 0} <- System.cmd("git", ["rev-parse", "HEAD"]) do
    "CommonsPub #{Mix.Project.config()[:version]} #{String.trim(version)}"
  else
    _ -> "CommonsPub #{Mix.Project.config()[:version]} dev"
  end

config :commons_pub, :instance,
  version: version,
  name: "CommonsPub",
  email: "root@localhost",
  description:
    "An instance of CommonsPub, a federated app ecosystem for open and cooperative networks",
  federation_publisher_modules: [ActivityPubWeb.Publisher],
  federation_reachability_timeout_days: 7,
  federating: true,
  rewrite_policy: []

### Stuff you probably won't want to change

config :commons_pub, ecto_repos: [CommonsPub.Repo]

config :commons_pub, CommonsPub.Repo,
  types: Forkable.PostgresTypes,
  migration_primary_key: [name: :id, type: :binary_id]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

if Mix.env() == :dev do
  config :mix_test_watch,
    clear: true,
    tasks: [
      "test"
    ]
end

config :mime, :types, %{
  "application/activity+json" => ["json"],
  "application/ld+json" => ["json"],
  "application/jrd+json" => ["json"]
}

# transactional emails

mail_blackhole = fn var ->
  IO.puts(
    "WARNING: The environment variable #{var} was not set or was set incorrectly, mail will NOT be sent."
  )

  config :commons_pub, CommonsPub.Mail.MailService, adapter: Bamboo.LocalAdapter
end

mail_mailgun = fn ->
  # depends on whether you're registered with Mailgun in EU, US, etc
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
              IO.puts("NOTE: Transactional emails will be sent through Mailgun.")

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

                      IO.puts("NOTE: Transactional emails will be sent through SMTP.")

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

config :argon2_elixir,
  # argon2id, see https://hexdocs.pm/argon2_elixir/Argon2.Stats.html
  argon2_type: 2

# Configures http settings, upstream proxy etc.
config :commons_pub, :http,
  proxy_url: nil,
  send_user_agent: true,
  adapter: [
    ssl_options: [
      # Workaround for remote server certificate chain issues
      partial_chain: &:hackney_connect.partial_chain/1,
      # We don't support TLS v1.3 yet
      versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"]
    ]
  ]

config :phoenix, :format_encoders, json: Jason
config :phoenix, :json_library, Jason

config :furlex, Furlex.Oembed, oembed_host: "https://oembed.com"

config :tesla, adapter: Tesla.Adapter.Gun

config :http_signatures, adapter: ActivityPub.Signature

config :commons_pub, ActivityPub.Adapter, adapter: CommonsPub.ActivityPub.Adapter

config :floki, :html_parser, Floki.HTMLParser.Html5ever

config :sentry,
  enable_source_code_context: true,
  root_source_code_path: File.cwd!()

config :commons_pub, :env, Mix.env()

config :pointers, Pointers.Pointer,
  source: "pointers_pointer",
  many_to_many: [
    tags: {
      # if(Code.ensure_loaded?(Taggable), do: Taggable, else: :taggable),
      Taggable,
      join_through: "tags_things",
      unique: true,
      join_keys: [pointer_id: :id, tag_id: :id],
      on_replace: :delete
    }
  ]

config :pointers, Pointers.Table, source: "pointers_table"

config :commons_pub, :ux,
  # prosemirror or ck5 as content editor:
  # editor: "prosemirror"
  editor: "ck5"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
