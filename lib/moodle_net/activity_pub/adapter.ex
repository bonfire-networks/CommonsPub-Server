defmodule MoodleNet.ActivityPub.Adapter do
  alias MoodleNet.Actors
  alias MoodleNet.Repo
  alias MoodleNet.Workers.APReceiverWorker
  require Logger

  @behaviour ActivityPub.Adapter

  def get_actor_by_username(username) do
    Actors.fetch_by_username(username)
  end

  defp maybe_fix_image_object(url) when is_binary(url), do: url
  defp maybe_fix_image_object(%{"url" => url}), do: url
  defp maybe_fix_image_object(_), do: nil

  def create_remote_actor(actor, username) do
    uri = URI.parse(actor["id"])
    ap_base = uri.scheme <> "://" <> uri.host

    peer =
      case Repo.get_by(MoodleNet.Peers.Peer, ap_url_base: ap_base) do
        nil ->
          {:ok, peer} = MoodleNet.Peers.create(%{ap_url_base: ap_base})
          peer

        peer ->
          peer
      end

    create_attrs = %{
      preferred_username: username,
      name: actor["name"],
      summary: actor["summary"],
      icon: maybe_fix_image_object(actor["icon"]),
      image: maybe_fix_image_object(actor["image"]),
      is_public: true,
      peer_id: peer.id
    }

    {:ok, created_actor} = Actors.create(create_attrs)

    object = ActivityPub.Object.get_by_ap_id(actor["id"])

    ActivityPub.Object.update(object, %{mn_pointer_id: created_actor.id})
    {:ok, created_actor}
  end

  def update_local_actor(actor, params) do
    with {:ok, local_actor} <-
           MoodleNet.Actors.fetch_by_username(actor.data["preferredUsername"]),
         {:ok, local_actor} <- MoodleNet.Actors.update(local_actor, params) do
      {:ok, local_actor}
    else
      {:error, e} -> {:error, e}
    end
  end

  def maybe_create_remote_actor(actor) do
    host = URI.parse(actor.data["id"]).host
    username = actor.data["preferredUsername"] <> "@" <> host

    case Actors.fetch_by_username(username) do
      {:error, _} ->
        with {:ok, _actor} <- create_remote_actor(actor.data, username) do
          :ok
        else
          _e -> {:error, "Couldn't create remote actor"}
        end

      _ ->
        :ok
    end
  end

  def handle_activity(activity) do
    APReceiverWorker.enqueue("handle_activity", %{"activity_id" => activity.id})
  end

  # FIXME: should go through a job queue
  def perform(:handle_activity, %{data: %{"type" => "Follow"}} = activity) do
    # FIXME: way too many queries
    with {:ok, ap_follower} <- ActivityPub.Actor.get_by_ap_id(activity.data["actor"]),
         {:ok, ap_followed} <- ActivityPub.Actor.get_by_ap_id(activity.data["object"]),
         {:ok, follower} <- Actors.fetch_by_username(ap_follower.username),
         {:ok, followed} <- Actors.fetch_by_username(ap_followed.username) do
      MoodleNet.Common.follow(follower, followed, %{is_public: true, is_muted: false})
      :ok
    else
      {:error, e} -> {:error, e}
    end
  end

  def perform(:handle_activity, %{data: %{"type" => "Undo", "object" => %{"type" => "Follow"}}}) do
    # TODO: need a context function to fetch an exisisting follow for this
  end

  def perform(:handle_activity, %{data: %{"type" => "Block"}} = activity) do
    # FIXME: way too many queries
    with {:ok, ap_blocker} <- ActivityPub.Actor.get_by_ap_id(activity.data["actor"]),
         {:ok, ap_blocked} <- ActivityPub.Actor.get_by_ap_id(activity.data["object"]),
         {:ok, blocker} <- Actors.fetch_by_username(ap_blocker.username),
         {:ok, blocked} <- Actors.fetch_by_username(ap_blocked.username) do
      MoodleNet.Common.block(blocker, blocked, %{
        is_public: true,
        is_muted: false,
        is_blocked: true
      })

      :ok
    else
      {:error, e} -> {:error, e}
    end
  end

  def perform(:handle_activity, %{data: %{"type" => "Undo", "object" => %{"type" => "Block"}}}) do
    # TODO: need a context function to fetch an exisisting block for this
  end

  def perform(:handle_activity, %{data: %{"type" => "Like"}} = activity) do
    with {:ok, ap_actor} <- ActivityPub.Actor.get_by_ap_id(activity.data["actor"]),
         {:ok, actor} <- MoodleNet.Actors.fetch_by_username(ap_actor.username),
         %ActivityPub.Object{} = object <-
           ActivityPub.Object.get_by_ap_id(activity.data["object"]),
         {:ok, liked} <- MoodleNet.Meta.find(object.mn_pointer_id) do
      MoodleNet.Common.like(actor, liked, %{is_public: true})
      :ok
    else
      {:error, e} -> {:error, e}
    end
  end

  def perform(:handle_activity, activity) do
    Logger.info("Unhandled activity type: #{activity.data["type"]}")
    :ok
  end
end
