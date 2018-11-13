defmodule MoodleNetWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :moodle_net

  #  socket "/socket", ActivityPubWeb.UserSocket,
  #    websocket: true,
  #    longpoll: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  # plug(Plug.Static, at: "/media", from: MoodleNet.Uploaders.Local.upload_path(), gzip: false)

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug(Plug.Static,
    at: "/",
    from: :moodle_net,
    gzip: false,
    only:
      ~w(css fonts images js robots.txt index.html static finmoji emoji packs sounds images instance sw.js favicon.ico)
  )

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug(TrailingFormatPlug)
  plug(Plug.RequestId)
  plug(Plug.Logger)

  plug(
    Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Jason,
    length: Application.get_env(:moodle_net, :instance) |> Keyword.get(:upload_limit),
    body_reader: {MoodleNetWeb.Plugs.DigestPlug, :read_body, []}
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  plug(
    Plug.Session,
    store: :cookie,
    key: "_moodle_net_key",
    signing_salt: "CqAoopA2"
  )

  plug(MoodleNetWeb.Router)

  @doc """
  Dynamically loads configuration from the system environment
  on startup.

  It receives the endpoint configuration from the config files
  and must return the updated configuration.
  """
  def load_from_system_env(config) do
    port = System.get_env("PORT") || raise "expected the PORT environment variable to be set"
    {:ok, Keyword.put(config, :http, [:inet6, port: port])}
  end
end
