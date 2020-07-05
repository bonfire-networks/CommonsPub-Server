# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.Router do
  @moduledoc """
  MoodleNet Router
  """
  import Phoenix.LiveView.Router

  use MoodleNetWeb, :router
  use Plug.ErrorHandler
  use Sentry.Plug

  if Mix.env() == :dev do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  pipeline :ensure_authenticated do
    plug(MoodleNetWeb.Plugs.EnsureAuthenticatedPlug)
  end

  @doc """
  Serve the GraphiQL API browser on /api/graphql
  """
  pipeline :api_browser do
    plug(:accepts, ["html", "json", "css", "js", "png", "jpg", "ico"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(MoodleNetWeb.Plugs.SetLocale)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  @doc """
  Serve GraphQL API queries
  """
  pipeline :graphql do
    plug MoodleNetWeb.Plugs.Auth
    plug MoodleNetWeb.Plugs.GraphQLContext
    plug :accepts, ["json"]
  end

  scope "/api/graphql" do
    pipe_through :graphql
    pipe_through :api_browser

    get "/schema", MoodleNetWeb.GraphQL.DevTools, :schema

    forward "/", Absinthe.Plug.GraphiQL,
      schema: MoodleNetWeb.GraphQL.Schema,
      interface: :playground,
      json_codec: Jason,
      pipeline: {MoodleNetWeb.GraphQL.Pipeline, :default_pipeline}
  end

  pipeline :well_known do
    plug(:accepts, ["json", "jrd+json"])
  end

  scope "/.well-known", ActivityPubWeb do
    pipe_through(:well_known)

    get "/webfinger", WebFingerController, :webfinger
    get "/nodeinfo", NodeinfoController, :schemas
  end

  @doc """
  Serve the mock homepage, or forward ActivityPub API requests to the AP module's router
  """

  pipeline :activity_pub do
    plug(:accepts, ["activity+json", "json", "html"])
  end

  pipeline :signed_activity_pub do
    plug(:accepts, ["activity+json", "json"])
    plug(ActivityPubWeb.Plugs.HTTPSignaturePlug)
  end

  ap_base_path = System.get_env("AP_BASE_PATH", "/pub")

  scope ap_base_path, ActivityPubWeb do
    pipe_through(:activity_pub)

    get "/objects/:uuid", ActivityPubController, :object
    get "/actors/:username", ActivityPubController, :actor
    get "/actors/:username/followers", ActivityPubController, :followers
    get "/actors/:username/following", ActivityPubController, :following
    get "/actors/:username/outbox", ActivityPubController, :noop
  end

  scope ap_base_path, ActivityPubWeb do
    pipe_through(:signed_activity_pub)

    post "/actors/:username/inbox", ActivityPubController, :inbox
    post "/shared_inbox", ActivityPubController, :inbox
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :put_root_layout, {MoodleNetWeb.LayoutView, :root}
    plug MoodleNetWeb.Plugs.SetLocale
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug MoodleNetWeb.Plugs.Auth
  end

  scope "/" do
    get "/", MoodleNetWeb.PageController, :index
    get "/.well-known/nodeinfo/:version", ActivityPubWeb.NodeinfoController, :nodeinfo
  end

  pipeline :liveview do
    plug MoodleNetWeb.Live.Plug
    plug :fetch_live_flash
  end

  scope "/", MoodleNetWeb do
    pipe_through :browser
    pipe_through :liveview

    # TODO redirect to instance or user depending on logged in
    live "/instance", InstanceLive

    live "/instance/:tab", InstanceLive

    live "/@:username", MemberLive
    live "/@:username/:tab", MemberLive

    live "/&:username", CommunityLive
    live "/&:username/:tab", CommunityLive

    live "/discussion/:id", DiscussionLive


    live "/login", LoginLive
    live "/signup", SignupLive

    pipe_through :ensure_authenticated

    live "/my", My.Live
    live "/my/profile", MemberLive
    live "/my/settings", SettingsLive
    live "/my/:tab", My.Live

    live "/proto/me", My.ProtoProfileLive

    live "/write", My.Publish.WriteLive
  end
end
