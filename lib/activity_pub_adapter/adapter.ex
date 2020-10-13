# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.ActivityPub.Adapter do
  alias CommonsPub.{Collections, Communities, Common, Repo, Resources, Threads, Users}
  alias CommonsPub.ActivityPub.Utils

  # alias CommonsPub.Characters

  alias CommonsPub.Search.Indexer

  alias CommonsPub.Meta.Pointers
  alias CommonsPub.Threads.Comments
  alias CommonsPub.Users.User
  alias CommonsPub.Communities.Community
  alias CommonsPub.Collections.Collection
  alias CommonsPub.Workers.APReceiverWorker
  require Logger

  @behaviour ActivityPub.Adapter

  def get_raw_actor_by_username(username) do
    # FIXME: this should be only one query
    with {:error, _e} <- Users.one([:default, username: username]),
         {:error, _e} <- Communities.one([:default, username: username]),
         {:error, _e} <- Collections.one([:default, username: username]),
         {:error, _e} <- CommonsPub.Characters.one([:default, username: username]) do
      {:error, "not found"}
    end
  end

  def get_raw_actor_by_id(id) do
    with {:error, _e} <- Users.one([:default, id: id]),
         {:error, _e} <- Communities.one([:default, id: id]),
         {:error, _e} <- Collections.one([:default, id: id]) do
      {:error, "not found"}
    end
  end

  def get_raw_actor_by_ap_id(ap_id) do
    # FIXME: this should not query the AP db
    with {:ok, actor} <- ActivityPub.Actor.get_or_fetch_by_ap_id(ap_id),
         {:ok, actor} <- get_actor_by_username(actor.username) do
      {:ok, actor}
    else
      {:error, e} -> {:error, e}
    end
  end

  defp maybe_create_image_object(url) when not is_nil(url) do
    %{
      "type" => "Image",
      "url" => url
    }
  end

  defp maybe_create_image_object(_), do: nil

  # TODO
  def get_and_format_collections_for_actor(_actor) do
    []
  end

  # TODO
  def get_and_format_resources_for_actor(_actor) do
    []
  end

  def get_creator_ap_id(actor) do
    with {:ok, actor} <- ActivityPub.Actor.get_cached_by_local_id(actor.creator_id) do
      actor.ap_id
    else
      {:error, _} -> nil
    end
  end

  def get_community_ap_id(actor) do
    with {:ok, actor} <- ActivityPub.Actor.get_cached_by_local_id(actor.community_id) do
      actor.ap_id
    else
      {:error, _} -> nil
    end
  end

  def format_local_actor(actor) do
    type =
      case actor do
        %CommonsPub.Users.User{} -> "Person"
        %CommonsPub.Communities.Community{} -> "MN:Community"
        %CommonsPub.Collections.Collection{} -> "MN:Collection"
        %CommonsPub.Characters.Character{} -> "CommonsPub:" <> Map.get(actor, :facet, "Character")
      end

    actor =
      case actor do
        %CommonsPub.Characters.Character{} ->
          with {:ok, profile} <- CommonsPub.Profiles.one([:default, id: actor.id]) do
            # IO.inspect(fed_profile: actor)
            # IO.inspect(fed_profile: profile)
            Map.merge(actor, profile)
          else
            _ ->
              actor
          end

        _ ->
          actor
      end

    icon_url = CommonsPub.Uploads.remote_url_from_id(actor.icon_id)

    image_url =
      if not Map.has_key?(actor, :resources) do
        CommonsPub.Uploads.remote_url_from_id(actor.image_id)
      else
        nil
      end

    ap_base_path = System.get_env("AP_BASE_PATH", "/pub")

    id =
      CommonsPub.Web.base_url() <> ap_base_path <> "/actors/#{actor.character.preferred_username}"

    data = %{
      "type" => type,
      "id" => id,
      "inbox" => "#{id}/inbox",
      "outbox" => "#{id}/outbox",
      "followers" => "#{id}/followers",
      "following" => "#{id}/following",
      "preferredUsername" => actor.character.preferred_username,
      "name" => actor.name,
      "summary" => Map.get(actor, :summary),
      "icon" => maybe_create_image_object(icon_url),
      "image" => maybe_create_image_object(image_url)
    }

    data =
      case data["type"] do
        "MN:Community" ->
          data
          |> Map.put("collections", get_and_format_collections_for_actor(actor))
          |> Map.put("attributedTo", get_creator_ap_id(actor))

        "MN:Collection" ->
          data
          |> Map.put("resources", get_and_format_resources_for_actor(actor))
          |> Map.put("attributedTo", get_creator_ap_id(actor))
          |> Map.put("context", get_community_ap_id(actor))

        _ ->
          data
      end

    %ActivityPub.Actor{
      id: actor.id,
      data: data,
      keys: actor.character.signing_key,
      local: true,
      ap_id: id,
      pointer_id: actor.id,
      username: actor.character.preferred_username,
      deactivated: false
    }
  end

  def get_actor_by_id(id) do
    case get_raw_actor_by_id(id) do
      {:ok, actor} ->
        {:ok, format_local_actor(actor)}
      _ -> {:error, "not found"}
    end
  end

  def get_actor_by_username(username) do
    case get_raw_actor_by_username(username) do
      {:ok, actor} ->
        {:ok, format_local_actor(actor)}
      _ -> {:error, "not found"}
    end
  end

  def get_actor_by_ap_id(ap_id) do
    case get_raw_actor_by_ap_id(ap_id) do
      {:ok, actor} ->
        {:ok, format_local_actor(actor)}
      _ -> {:error, "not found"}
    end
  end

  defp maybe_fix_image_object(url) when is_binary(url), do: url
  defp maybe_fix_image_object(%{"url" => url}), do: url
  defp maybe_fix_image_object(_), do: nil

  defp maybe_create_image_object(url, _actor) when is_nil(url), do: nil

  defp maybe_create_image_object(url, actor) do
    case CommonsPub.Uploads.upload(CommonsPub.Uploads.ImageUploader, actor, %{url: url}, %{}) do
      {:ok, upload} -> upload.id
      {:error, _} -> nil
    end
  end

  defp maybe_create_icon_object(url, _actor) when is_nil(url), do: nil

  defp maybe_create_icon_object(url, actor) do
    case CommonsPub.Uploads.upload(CommonsPub.Uploads.IconUploader, actor, %{url: url}, %{}) do
      {:ok, upload} -> upload.id
      {:error, _} -> nil
    end
  end

  # TODO: Rewrite this whole thing tbh
  def create_remote_actor(actor, username) do
    uri = URI.parse(actor["id"])
    ap_base = uri.scheme <> "://" <> uri.host

    peer =
      case Repo.get_by(CommonsPub.Peers.Peer, ap_url_base: ap_base) do
        nil ->
          {:ok, peer} = CommonsPub.Peers.create(%{ap_url_base: ap_base, domain: uri.host})
          peer

        peer ->
          peer
      end

    name =
      case actor["name"] do
        nil -> actor["preferredUsername"]
        "" -> actor["preferredUsername"]
        _ -> actor["name"]
      end

    icon_url = maybe_fix_image_object(actor["icon"])
    image_url = maybe_fix_image_object(actor["image"])

    create_attrs = %{
      preferred_username: username,
      name: name,
      summary: actor["summary"],
      is_public: true,
      is_local: false,
      is_disabled: false,
      peer_id: peer.id,
      canonical_url: actor["id"]
    }

    {:ok, created_actor, creator} =
      case actor["type"] do
        "Person" ->
          {:ok, created_actor} = CommonsPub.Users.register(create_attrs)
          {:ok, created_actor, created_actor}

        "MN:Community" ->
          {:ok, creator} = get_actor_by_ap_id(actor["attributedTo"])
          {:ok, created_actor} = CommonsPub.Communities.create_remote(creator, create_attrs)
          {:ok, created_actor, creator}

        "MN:Collection" ->
          {:ok, creator} = get_actor_by_ap_id(actor["attributedTo"])
          {:ok, community} = get_actor_by_ap_id(actor["context"])

          {:ok, created_actor} =
            CommonsPub.Collections.create_remote(creator, community, create_attrs)

          {:ok, created_actor, creator}
      end

    icon_id = maybe_create_icon_object(icon_url, creator)
    image_id = maybe_create_image_object(image_url, creator)

    {:ok, updated_actor} =
      case created_actor do
        %CommonsPub.Users.User{} ->
          Users.update_remote(created_actor, %{icon_id: icon_id, image_id: image_id})

        %CommonsPub.Communities.Community{} ->
          Communities.update(%User{}, created_actor, %{icon_id: icon_id, image_id: image_id})

        %CommonsPub.Collections.Collection{} ->
          Collections.update(%User{}, created_actor, %{icon_id: icon_id, image_id: image_id})
      end

    object = ActivityPub.Object.get_cached_by_ap_id(actor["id"])

    ActivityPub.Object.update(object, %{pointer_id: created_actor.id})
    Indexer.maybe_index_object(updated_actor)
    {:ok, updated_actor}
  end

  def update_local_actor(actor, params) do
    keys = Map.get(params, :keys)
    params = Map.put(params, :signing_key, keys)
    with {:ok, local_actor} <-
           CommonsPub.Characters.one(username: actor.data["preferredUsername"]),
         {:ok, local_actor} <-
           CommonsPub.Characters.update(%User{}, local_actor, params),
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
           icon_id: maybe_create_icon_object(maybe_fix_image_object(data["icon"]), actor),
           image_id: maybe_create_image_object(maybe_fix_image_object(data["image"]), actor)
         },
         {:ok, user} <- CommonsPub.Users.update_remote(actor, params) do
      {:ok, user}
    else
      {:error, e} -> {:error, e}
    end
  end

  def update_community(actor, data) do
    with {:ok, creator} <- Users.one([:default, id: actor.creator_id]),
         params <- %{
           name: data["name"],
           summary: data["summary"],
           icon_id: maybe_create_icon_object(maybe_fix_image_object(data["icon"]), creator),
           image_id: maybe_create_image_object(maybe_fix_image_object(data["image"]), creator)
         },
         {:ok, comm} <- CommonsPub.Communities.update(creator, actor, params) do
      {:ok, comm}
    else
      {:error, e} -> {:error, e}
    end
  end

  def update_collection(actor, data) do
    with {:ok, creator} <- Users.one([:default, id: actor.creator_id]),
         params <- %{
           name: data["name"],
           summary: data["summary"],
           icon_id: maybe_create_icon_object(maybe_fix_image_object(data["icon"]), creator)
         },
         {:ok, coll} <- CommonsPub.Collections.update(creator, actor, params) do
      {:ok, coll}
    else
      {:error, e} -> {:error, e}
    end
  end

  def update_remote_actor(actor_object) do
    data = actor_object.data

    with {:ok, actor} <- get_actor_by_id(actor_object.pointer_id) do
      case actor do
        %CommonsPub.Users.User{} ->
          update_user(actor, data)

        %CommonsPub.Communities.Community{} ->
          update_community(actor, data)

        %CommonsPub.Collections.Collection{} ->
          update_collection(actor, data)
      end
    end
  end

  def maybe_create_remote_actor(actor) do
    host = URI.parse(actor.data["id"]).host
    username = actor.data["preferredUsername"] <> "@" <> host

    case CommonsPub.Characters.one(username: username) do
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
    APReceiverWorker.enqueue("handle_activity", %{
      "activity_id" => activity.id,
      "activity" => activity.data
    })
  end

  def handle_create(
        _activity,
        %{data: %{"type" => "Note", "inReplyTo" => in_reply_to}} = object
      )
      when not is_nil(in_reply_to) do
    # This will fail if the reply isn't in database
    with parent_id <- Utils.get_pointer_id_by_ap_id(in_reply_to),
         {:ok, parent_comment} <- Comments.one(id: parent_id),
         {:ok, thread} <- Threads.one(id: parent_comment.thread_id),
         {:ok, actor} <- get_actor_by_ap_id(object.data["actor"]),
         {:ok, comment} <-
           Comments.create_reply(actor, thread, parent_comment, %{
             is_public: object.public,
             content: object.data["content"],
             is_local: false,
             canonical_url: object.data["id"]
           }) do
      ActivityPub.Object.update(object, %{pointer_id: comment.id})
      :ok
    else
      {:error, e} -> {:error, e}
    end
  end

  def handle_create(
        %{data: %{"context" => context}} = _activity,
        %{data: %{"type" => "Note"}} = object
      ) do
    with pointer_id <- CommonsPub.ActivityPub.Utils.get_pointer_id_by_ap_id(context),
         {:ok, pointer} <- Pointers.one(id: pointer_id),
         parent = CommonsPub.Meta.Pointers.follow!(pointer),
         {:ok, actor} <- get_actor_by_ap_id(object.data["actor"]),
         {:ok, thread} <- Threads.create(actor, %{is_public: true, is_local: false}, parent),
         {:ok, comment} <-
           Comments.create(actor, thread, %{
             is_public: object.public,
             content: object.data["content"],
             is_local: false,
             canonical_url: object.data["id"]
           }) do
      ActivityPub.Object.update(object, %{pointer_id: comment.id})
      :ok
    else
      {:error, e} -> {:error, e}
    end
  end

  def handle_create(
        %{data: %{"context" => context}} = _activity,
        %{data: %{"type" => "Document", "actor" => actor}} = object
      ) do
    with {:ok, collection} <- get_actor_by_ap_id(context),
         {:ok, actor} <- get_actor_by_ap_id(actor),
         {:ok, content} <-
           CommonsPub.Uploads.upload(
             CommonsPub.Uploads.ResourceUploader,
             actor,
             %{url: object.data["url"]},
             %{is_public: true}
           ),
         icon_url <- maybe_fix_image_object(object.data["icon"]),
         icon_id <- maybe_create_icon_object(icon_url, actor),
         attrs <- %{
           is_public: true,
           is_local: false,
           is_disabled: false,
           name: object.data["name"],
           canonical_url: object.data["id"],
           summary: object.data["summary"],
           content_id: content.id,
           license: object.data["tag"],
           icon_id: icon_id,
           author: Utils.get_author(object.data["author"]),
           subject: object.data["subject"],
           level: object.data["level"],
           language: object.data["language"]
         },
         {:ok, resource} <-
           CommonsPub.Resources.create(actor, collection, attrs) do
      ActivityPub.Object.update(object, %{pointer_id: resource.id})
      # Indexer.maybe_index_object(resource) # now being called in CommonsPub.Resources.create
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
    object = ActivityPub.Object.get_cached_by_ap_id(object_id)
    handle_create(activity, object)
  end

  def perform(:handle_activity, %{data: %{"type" => "Follow"}} = activity) do
    with {:ok, follower} <- get_actor_by_ap_id(activity.data["actor"]),
         {:ok, followed} <- get_actor_by_ap_id(activity.data["object"]),
         {:ok, _} <-
           CommonsPub.Follows.create(follower, followed, %{
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
         {:ok, follow} <-
           CommonsPub.Follows.one(deleted: false, creator: follower.id, context: followed.id),
         {:ok, _} <- CommonsPub.Follows.soft_delete(follower, follow) do
      :ok
    else
      {:error, e} -> {:error, e}
    end
  end

  def perform(:handle_activity, %{data: %{"type" => "Block"}} = activity) do
    with {:ok, blocker} <- get_actor_by_ap_id(activity.data["actor"]),
         {:ok, blocked} <- get_actor_by_ap_id(activity.data["object"]),
         {:ok, _} <-
           CommonsPub.Blocks.create(blocker, blocked, %{
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
         {:ok, block} <- CommonsPub.Blocks.find(blocker, blocked),
         {:ok, _} <- CommonsPub.Blocks.soft_delete(blocker, block) do
      :ok
    else
      {:error, e} -> {:error, e}
    end
  end

  def perform(:handle_activity, %{data: %{"type" => "Like"}} = activity) do
    with {:ok, ap_actor} <- ActivityPub.Actor.get_by_ap_id(activity.data["actor"]),
         {:ok, actor} <- get_actor_by_username(ap_actor.username),
         %ActivityPub.Object{} = object <-
           ActivityPub.Object.get_cached_by_ap_id(activity.data["object"]),
         {:ok, liked} <- Pointers.one(id: object.pointer_id),
         liked = CommonsPub.Meta.Pointers.follow!(liked),
         {:ok, _} <-
           CommonsPub.Likes.create(actor, liked, %{
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
    object = ActivityPub.Object.get_cached_by_ap_id(obj_id)

    if object.data["type"] in ["Person", "MN:Community", "MN:Collection", "Group"] do
      with {:ok, actor} <- get_actor_by_ap_id(activity.data["object"]),
           {:ok, _} <-
             (case actor do
                %User{} -> CommonsPub.Users.soft_delete_remote(actor)
                %Community{} -> CommonsPub.Communities.soft_delete(%User{}, actor)
                %Collection{} -> CommonsPub.Collections.soft_delete(%User{}, actor)
              end) do
        Indexer.maybe_delete_object(actor)
        :ok
      else
        {:error, e} ->
          {:error, e}
      end
    else
      case object.data["formerType"] do
        "Note" ->
          with {:ok, comment} <- Comments.one(id: object.pointer_id),
               {:ok, _} <- Common.soft_delete(comment) do
            :ok
          end

        "Document" ->
          with {:ok, resource} <- Resources.one(id: object.pointer_id),
               {:ok, _} <- Common.soft_delete(resource) do
            Indexer.maybe_delete_object(resource)
            :ok
          end
      end
    end
  end

  def perform(
        :handle_activity,
        %{data: %{"type" => "Update", "object" => %{"id" => ap_id}}} = _activity
      ) do
    with {:ok, actor} <- ActivityPub.Actor.get_cached_by_ap_id(ap_id),
         {:ok, actor} <- update_remote_actor(actor) do
      Indexer.maybe_index_object(actor)
      :ok
    end
  end

  def perform(:handle_activity, %{data: %{"type" => "Flag", "object" => objects}} = activity)
      when length(objects) > 1 do
    with {:ok, actor} <- get_actor_by_ap_id(activity.data["actor"]) do
      activity.data["object"]
      |> Enum.map(fn ap_id -> ActivityPub.Object.get_cached_by_ap_id(ap_id) end)
      # Filter nils
      |> Enum.filter(fn object -> object end)
      |> Enum.map(fn object ->
        CommonsPub.Meta.Pointers.one!(id: object.pointer_id)
        |> CommonsPub.Meta.Pointers.follow!()
      end)
      |> Enum.each(fn object ->
        CommonsPub.Flags.create(actor, object, %{
          message: activity.data["content"],
          is_local: false
        })
      end)

      :ok
    end
  end

  def perform(:handle_activity, %{data: %{"type" => "Flag", "object" => [account]}} = activity) do
    with {:ok, actor} <- get_actor_by_ap_id(activity.data["actor"]),
         {:ok, account} <- get_actor_by_ap_id(account) do
      CommonsPub.Flags.create(actor, account, %{
        message: activity.data["content"],
        is_local: false
      })

      :ok
    end
  end

  def perform(:handle_activity, activity) do
    Logger.info("Unhandled activity type: #{activity.data["type"]}")
    :ok
  end
end
