# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.ActivityPub.Adapter do
  alias MoodleNet.{Actors, Collections, Communities, Repo, Users}
  alias MoodleNet.ActivityPub.Utils
  alias MoodleNet.Workers.APReceiverWorker
  require Logger

  @behaviour ActivityPub.Adapter

  def get_actor_by_username(username) do
    with {:ok, actor} <- Actors.fetch_any_by_username(username) do
      actor =
        actor
	|> Actors.preload_alias()
	|> Actors.juggle_alias()

      {:ok, actor}
    else
      _e -> {:error, "not found"}
    end
  end

  def get_actor_by_id(id) do
    with {:error, _e} <- Users.fetch(id),
         {:error, _e} <- Communities.fetch_private(id),
         {:error, _e} <- Collections.fetch(id) do
      {:error, "not found"}
    end
  end

  def get_actor_by_ap_id(ap_id) do
    with {:ok, actor} <- ActivityPub.Actor.get_by_ap_id(ap_id),
         {:ok, actor} <- get_actor_by_username(actor.username) do
      {:ok, actor}
    else
      {:error, e} -> {:error, e}
    end
  end

  defp maybe_fix_image_object(url) when is_binary(url), do: url
  defp maybe_fix_image_object(%{"url" => url}), do: url
  defp maybe_fix_image_object(_), do: nil

  # TODO: Add error handling lol
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
      name: actor["name"] || actor["preferredUsername"],
      summary: actor["summary"],
      icon: maybe_fix_image_object(actor["icon"]),
      image: maybe_fix_image_object(actor["image"]),
      is_public: true,
      is_disabled: false,
      peer_id: peer.id,
      canonical_url: actor["id"]
    }

    {:ok, created_actor} =
      case actor["type"] do
        "Person" ->
          MoodleNet.Users.register_remote(create_attrs)

        "MN:Community" ->
          {:ok, ap_creator} = ActivityPub.Actor.get_by_ap_id(actor["attributedTo"])
          {:ok, creator} = get_actor_by_username(ap_creator.username)
          MoodleNet.Communities.create(creator, create_attrs)

        "MN:Collection" ->
          {:ok, ap_creator} = ActivityPub.Actor.get_by_ap_id(actor["attributedTo"])
          {:ok, creator} = get_actor_by_username(ap_creator.username)
          {:ok, ap_community} = ActivityPub.Actor.get_by_ap_id(actor["context"])
          {:ok, community} = get_actor_by_username(ap_community.username)
          MoodleNet.Collections.create(community, creator, create_attrs)
      end

    object = ActivityPub.Object.get_by_ap_id(actor["id"])

    ActivityPub.Object.update(object, %{mn_pointer_id: created_actor.id})
    {:ok, created_actor}
  end

  def update_local_actor(actor, params) do
    with {:ok, local_actor} <-
           MoodleNet.Actors.fetch_by_username(actor.data["preferredUsername"]),
         {:ok, local_actor} <- MoodleNet.Actors.update(local_actor, params),
         {:ok, local_actor} <- get_actor_by_username(local_actor.preferred_username) do
      {:ok, local_actor}
    else
      {:error, e} -> {:error, e}
    end
  end

  def update_user(actor, data) do
    with params <- %{
           name: data["name"],
           summary: data["summary"],
           icon: maybe_fix_image_object(data["icon"]),
           image: maybe_fix_image_object(data["image"])
         },
         {:ok, _} <- MoodleNet.Users.update_remote(actor, params) do
      :ok
    else
      {:error, e} -> {:error, e}
    end
  end

  def update_community(actor, data) do
    with params <- %{
           name: data["name"],
           summary: data["summary"],
           icon: maybe_fix_image_object(data["icon"]),
           image: maybe_fix_image_object(actor["image"])
         },
         {:ok, _} <- MoodleNet.Communities.update(actor, params) do
      :ok
    else
      {:error, e} -> {:error, e}
    end
  end

  def update_collection(actor, data) do
    with params <- %{
           name: data["name"],
           summary: data["summary"],
           icon: maybe_fix_image_object(data["icon"])
         },
         {:ok, _} <- MoodleNet.Collections.update(actor, params) do
      :ok
    else
      {:error, e} -> {:error, e}
    end
  end

  def update_remote_actor(actor_object) do
    data = actor_object.data

    with {:ok, actor} <- get_actor_by_id(actor_object.mn_pointer_id) do
      case actor do
        %MoodleNet.Users.User{} ->
          update_user(actor, data)

        %MoodleNet.Communities.Community{} ->
          update_community(actor, data)

        %MoodleNet.Collections.Collection{} ->
          update_collection(actor, data)
      end
    end
  end

  def maybe_create_remote_actor(actor) do
    host = URI.parse(actor.data["id"]).host
    username = actor.data["preferredUsername"] <> "@" <> host

    case Repo.fetch_by(MoodleNet.Actors.Actor, %{preferred_username: username}) do
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

  def handle_create(
        _activity,
        %{data: %{"type" => "Note", "inReplyTo" => in_reply_to}} = object
      ) do
    with parent_id <- Utils.get_pointer_id_by_ap_id(in_reply_to),
         {:ok, parent_comment} <- MoodleNet.Comments.fetch_comment(parent_id),
         {:ok, thread} <- MoodleNet.Comments.fetch_thread(parent_comment.thread_id),
         {:ok, actor} <- get_actor_by_ap_id(object.data["actor"]),
         {:ok, _} <-
           MoodleNet.Comments.create_comment_reply(thread, actor, parent_comment, %{
             is_public: object.public,
             content: object.data["content"],
             is_local: false,
             canonical_url: object.data["id"]
           }) do
      :ok
    else
      {:error, e} -> {:error, e}
    end
  end

  def handle_create(
        %{data: %{"context" => context}} = _activity,
        %{data: %{"type" => "Note"}} = object
      ) do
    with pointer_id <- MoodleNet.ActivityPub.Utils.get_pointer_id_by_ap_id(context),
         {:ok, pointer} <- MoodleNet.Meta.find(pointer_id),
         {:ok, parent} <- MoodleNet.Meta.follow(pointer),
         {:ok, actor} <- get_actor_by_ap_id(object.data["actor"]),
         {:ok, thread} <-
           MoodleNet.Comments.create_thread(parent, actor, %{is_public: true, is_local: false}),
         {:ok, _} <-
           MoodleNet.Comments.create_comment(thread, actor, %{
             is_public: object.public,
             content: object.data["content"],
             is_local: false,
             canonical_url: object.data["id"]
           }) do
      :ok
    else
      {:error, e} -> {:error, e}
    end
  end

  def handle_create(
        %{data: %{"context" => context}} = _activity,
        %{data: %{"type" => "Document", "actor" => actor}} = object
      ) do
    with {:ok, ap_collection} <- ActivityPub.Actor.get_by_ap_id(context),
         {:ok, collection} <- get_actor_by_username(ap_collection.username),
         {:ok, ap_actor} <- ActivityPub.Actor.get_by_ap_id(actor),
         {:ok, actor} <- get_actor_by_username(ap_actor.username),
         attrs <- %{
           is_public: true,
           is_local: false,
           is_disabled: false,
           name: object.data["name"],
           canonical_url: object.data["id"],
           summary: object.data["summary"],
           url: object.data["url"],
           license: object.data["tag"],
           icon: object.data["icon"]
         },
         {:ok, _} <-
           MoodleNet.Resources.create(collection, actor, attrs) do
      :ok
    else
      {:error, e} -> {:error, e}
    end
  end

  def handle_create(_activity, object) do
    Logger.info("Unhandled object type: #{object.data["type"]}")
    :ok
  end

  def perform(
        :handle_activity,
        %{
          data: %{
            "type" => "Create",
            "object" => object_id
          }
        } = activity
      ) do
    object = ActivityPub.Object.get_by_ap_id(object_id)
    handle_create(activity, object)
  end

  def perform(:handle_activity, %{data: %{"type" => "Follow"}} = activity) do
    with {:ok, follower} <- get_actor_by_ap_id(activity.data["actor"]),
         {:ok, followed} <- get_actor_by_ap_id(activity.data["object"]),
         {:ok, _} <-
           MoodleNet.Common.follow(follower, followed, %{
             is_public: true,
             is_muted: false,
             is_local: false,
             canonical_url: activity.data["id"]
           }) do
      :ok
    else
      {:error, e} -> {:error, e}
    end
  end

  def perform(
        :handle_activity,
        %{data: %{"type" => "Undo", "object" => %{"type" => "Follow"}}} = activity
      ) do
    with {:ok, follower} <- get_actor_by_ap_id(activity.data["object"]["actor"]),
         {:ok, followed} <- get_actor_by_ap_id(activity.data["object"]["object"]),
         {:ok, follow} <- MoodleNet.Common.find_follow(follower, followed),
         {:ok, _} <- MoodleNet.Common.undo_follow(follow) do
      :ok
    else
      {:error, e} -> {:error, e}
    end
  end

  def perform(:handle_activity, %{data: %{"type" => "Block"}} = activity) do
    with {:ok, blocker} <- get_actor_by_ap_id(activity.data["actor"]),
         {:ok, blocked} <- get_actor_by_ap_id(activity.data["object"]),
         {:ok, _} <-
           MoodleNet.Common.block(blocker, blocked, %{
             is_public: true,
             is_muted: false,
             is_blocked: true,
             is_local: false,
             canonical_url: activity.data["id"]
           }) do
      :ok
    else
      {:error, e} -> {:error, e}
    end
  end

  def perform(
        :handle_activity,
        %{data: %{"type" => "Undo", "object" => %{"type" => "Block"}}} = activity
      ) do
    with {:ok, blocker} <- get_actor_by_ap_id(activity.data["object"]["actor"]),
         {:ok, blocked} <- get_actor_by_ap_id(activity.data["object"]["object"]),
         {:ok, block} <- MoodleNet.Common.find_block(blocker, blocked),
         {:ok, _} <- MoodleNet.Common.delete_block(block) do
      :ok
    else
      {:error, e} -> {:error, e}
    end
  end

  def perform(:handle_activity, %{data: %{"type" => "Like"}} = activity) do
    with {:ok, ap_actor} <- ActivityPub.Actor.get_by_ap_id(activity.data["actor"]),
         {:ok, actor} <- get_actor_by_username(ap_actor.username),
         %ActivityPub.Object{} = object <-
           ActivityPub.Object.get_by_ap_id(activity.data["object"]),
         {:ok, liked} <- MoodleNet.Meta.find(object.mn_pointer_id),
         {:ok, liked} <- MoodleNet.Meta.follow(liked),
         {:ok, _} <-
           MoodleNet.Common.like(actor, liked, %{
             is_public: true,
             is_local: false,
             canonical_url: activity.data["id"]
           }) do
      :ok
    else
      {:error, e} -> {:error, e}
    end
  end

  def perform(
        :handle_activity,
        %{data: %{"type" => "Delete", "object" => obj_id}} = activity
      ) do
    object = ActivityPub.Object.get_by_ap_id(obj_id)

    if object.data["type"] in ["Person", "MN:Community", "MN:Collection"] do
      with {:ok, actor} <- get_actor_by_ap_id(activity.data["object"]),
           {:ok, _} <-
             (case object.data["type"] do
                "Person" -> MoodleNet.Users.soft_delete_remote(actor)
                "MN:Community" -> MoodleNet.Communities.soft_delete(actor)
                "MN:Collection" -> MoodleNet.Collections.soft_delete(actor)
              end) do
        :ok
      else
        {:error, e} ->
          {:error, e}
      end
    else
      case object.data["formerType"] do
        "Note" ->
          with {:ok, comment} <- MoodleNet.Comments.fetch_comment(object.mn_pointer_id),
               {:ok, _} <- MoodleNet.Comments.soft_delete_comment(comment) do
            :ok
          end

        "Document" ->
          with {:ok, resource} <- MoodleNet.Resources.fetch(object.mn_pointer_id),
               {:ok, _} <- MoodleNet.Resources.soft_delete(resource) do
            :ok
          end
      end
    end
  end

  def perform(:handle_activity, activity) do
    Logger.info("Unhandled activity type: #{activity.data["type"]}")
    :ok
  end
end
