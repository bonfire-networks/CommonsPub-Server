defmodule CommonsPub.ActivityPub.Receiver do
  require Logger
  alias CommonsPub.ActivityPub.Utils
  alias CommonsPub.Search.Indexer

  # Activity: Create
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

  # Activity: Follow
  def perform(:handle_activity, %{data: %{"type" => "Follow"}} = activity) do
    with {:ok, follower} <-
           CommonsPub.ActivityPub.Utils.get_raw_actor_by_ap_id(activity.data["actor"]),
         {:ok, followed} <-
           CommonsPub.ActivityPub.Utils.get_raw_actor_by_ap_id(activity.data["object"]),
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

  # Unfollow (Activity: Undo, Object: Follow)
  def perform(
        :handle_activity,
        %{data: %{"type" => "Undo", "object" => %{"type" => "Follow"}}} = activity
      ) do
    with {:ok, follower} <-
           CommonsPub.ActivityPub.Utils.get_raw_actor_by_ap_id(activity.data["object"]["actor"]),
         {:ok, followed} <-
           CommonsPub.ActivityPub.Utils.get_raw_actor_by_ap_id(activity.data["object"]["object"]),
         {:ok, follow} <-
           CommonsPub.Follows.one(deleted: false, creator: follower.id, context: followed.id),
         {:ok, _} <- CommonsPub.Follows.soft_delete(follower, follow) do
      :ok
    else
      {:error, e} -> {:error, e}
    end
  end

  # Activity: Block
  def perform(:handle_activity, %{data: %{"type" => "Block"}} = activity) do
    with {:ok, blocker} <-
           CommonsPub.ActivityPub.Utils.get_raw_actor_by_ap_id(activity.data["actor"]),
         {:ok, blocked} <-
           CommonsPub.ActivityPub.Utils.get_raw_actor_by_ap_id(activity.data["object"]),
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

  # Unblock (Activity: Undo, Object: Block)
  def perform(
        :handle_activity,
        %{data: %{"type" => "Undo", "object" => %{"type" => "Block"}}} = activity
      ) do
    with {:ok, blocker} <-
           CommonsPub.ActivityPub.Utils.get_raw_actor_by_ap_id(activity.data["object"]["actor"]),
         {:ok, blocked} <-
           CommonsPub.ActivityPub.Utils.get_raw_actor_by_ap_id(activity.data["object"]["object"]),
         {:ok, block} <- CommonsPub.Blocks.find(blocker, blocked),
         {:ok, _} <- CommonsPub.Blocks.soft_delete(blocker, block) do
      :ok
    else
      {:error, e} -> {:error, e}
    end
  end

  # Activity: Like
  def perform(:handle_activity, %{data: %{"type" => "Like"}} = activity) do
    with {:ok, ap_actor} <- ActivityPub.Actor.get_by_ap_id(activity.data["actor"]),
         {:ok, actor} <-
           CommonsPub.ActivityPub.Utils.get_raw_character_by_username(ap_actor.username),
         %ActivityPub.Object{} = object <-
           ActivityPub.Object.get_cached_by_ap_id(activity.data["object"]),
         {:ok, liked} <- CommonsPub.Meta.Pointers.one(id: object.pointer_id),
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

  # Activity: Flag (many objects)
  def perform(:handle_activity, %{data: %{"type" => "Flag", "object" => objects}} = activity)
      when length(objects) > 1 do
    with {:ok, actor} <-
           CommonsPub.ActivityPub.Utils.get_raw_actor_by_ap_id(activity.data["actor"]) do
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

  # Activity: Flag (one object)
  def perform(:handle_activity, %{data: %{"type" => "Flag", "object" => [account]}} = activity) do
    with {:ok, actor} <-
           CommonsPub.ActivityPub.Utils.get_raw_actor_by_ap_id(activity.data["actor"]),
         {:ok, account} <- CommonsPub.ActivityPub.Utils.get_raw_actor_by_ap_id(account) do
      CommonsPub.Flags.create(actor, account, %{
        message: activity.data["content"],
        is_local: false
      })

      :ok
    end
  end

  # Activity: Delete
  def perform(
        :handle_activity,
        %{data: %{"type" => "Delete", "object" => obj_id}} = activity
      ) do
    object = ActivityPub.Object.get_cached_by_ap_id(obj_id)

    # FIXME: support other actor types
    if object.data["type"] in [
         "Person",
         "Group",
         "Organization",
         "Application",
         "Service",
         "Community",
         "MN:Collection",
         "CommonsPub:Character"
       ] do
      with {:ok, actor} <-
             CommonsPub.ActivityPub.Utils.get_raw_actor_by_ap_id(activity.data["object"]),
           {:ok, _} <- CommonsPub.Common.Deletion.trigger_soft_delete(actor, true) do
        :ok
      else
        {:error, e} ->
          Logger.warn("Could not find actor to delete")
          {:error, e}
      end
    else
    # FIXME: support other object types
      case object.data["formerType"] do
        "Note" ->
          with {:ok, comment} <- CommonsPub.Threads.Comments.one(id: object.pointer_id),
               {:ok, _} <- CommonsPub.Common.Deletion.soft_delete(comment) do
            :ok
          end

        "Document" ->
          with {:ok, resource} <- CommonsPub.Resources.one(id: object.pointer_id),
               {:ok, _} <- CommonsPub.Common.Deletion.soft_delete(resource) do
            Indexer.maybe_delete_object(resource)
            :ok
          end
      end
    end
  end

  # Activity: Update
  def perform(
        :handle_activity,
        %{data: %{"type" => "Update", "object" => %{"id" => ap_id}}} = _activity
      ) do
    with {:ok, actor} <- ActivityPub.Actor.get_cached_by_ap_id(ap_id),
         {:ok, actor} <- CommonsPub.ActivityPub.Adapter.update_remote_actor(actor) do
      Indexer.maybe_index_object(actor)
      :ok
    end
  end

  def perform(:handle_activity, activity) do
    Logger.warn("ActivityPub - ignored incoming activity")
    Logger.info("Unhandled activity type: #{activity.data["type"]}")
    Logger.info("Unhandled object type: #{activity.data["object"]["type"]}")
    :ok
  end

  def handle_create(
        _activity,
        %{data: %{"type" => "Note", "inReplyTo" => in_reply_to}} = object
      )
      when not is_nil(in_reply_to) do
    # This will fail if the reply isn't in database
    with parent_id <- Utils.get_pointer_id_by_ap_id(in_reply_to),
         {:ok, parent_comment} <- CommonsPub.Threads.Comments.one(id: parent_id),
         {:ok, thread} <- CommonsPub.Threads.one(id: parent_comment.thread_id),
         {:ok, actor} <-
           CommonsPub.ActivityPub.Utils.get_raw_actor_by_ap_id(object.data["actor"]),
         {:ok, comment} <-
           CommonsPub.Threads.Comments.create_reply(actor, thread, parent_comment, %{
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
        # TODO: dedup with prev function
    with pointer_id <- CommonsPub.ActivityPub.Utils.get_pointer_id_by_ap_id(context),
         {:ok, pointer} <- CommonsPub.Meta.Pointers.one(id: pointer_id),
         parent = CommonsPub.Meta.Pointers.follow!(pointer),
         {:ok, actor} <-
           CommonsPub.ActivityPub.Utils.get_raw_actor_by_ap_id(object.data["actor"]),
         {:ok, thread} <-
           CommonsPub.Threads.create(actor, %{is_public: true, is_local: false}, parent),
         {:ok, comment} <-
           CommonsPub.Threads.Comments.create(actor, thread, %{
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
    with {:ok, collection} <- CommonsPub.ActivityPub.Utils.get_raw_actor_by_ap_id(context),
         {:ok, actor} <- CommonsPub.ActivityPub.Utils.get_raw_actor_by_ap_id(actor),
         {:ok, content} <-
           CommonsPub.Uploads.upload(
             CommonsPub.Uploads.ResourceUploader,
             actor,
             %{url: object.data["url"]},
             %{is_public: true}
           ),
         icon_url <- CommonsPub.ActivityPub.Utils.maybe_fix_image_object(object.data["icon"]),
         icon_id <- CommonsPub.ActivityPub.Utils.maybe_create_icon_object(icon_url, actor),
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
           author: CommonsPub.ActivityPub.Utils.get_author(object.data["author"]),
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

  # TODO: Rewrite this whole thing tbh
  def create_remote_actor(actor, username) do
    uri = URI.parse(actor["id"])
    ap_base = uri.scheme <> "://" <> uri.host

    peer =
      case CommonsPub.Repo.get_by(CommonsPub.Peers.Peer, ap_url_base: ap_base) do
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

    icon_url = CommonsPub.ActivityPub.Utils.maybe_fix_image_object(actor["icon"])
    image_url = CommonsPub.ActivityPub.Utils.maybe_fix_image_object(actor["image"])

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

        "Group" ->
          {:ok, creator} =
            CommonsPub.ActivityPub.Utils.get_raw_actor_by_ap_id(actor["attributedTo"])

          {:ok, created_actor} = CommonsPub.Communities.create_remote(creator, create_attrs)
          {:ok, created_actor, creator}

        "MN:Collection" ->
          {:ok, creator} =
            CommonsPub.ActivityPub.Utils.get_raw_actor_by_ap_id(actor["attributedTo"])

          {:ok, community} = CommonsPub.ActivityPub.Utils.get_raw_actor_by_ap_id(actor["context"])

          {:ok, created_actor} =
            CommonsPub.Collections.create_remote(creator, community, create_attrs)

          {:ok, created_actor, creator}
      end

    icon_id = CommonsPub.ActivityPub.Utils.maybe_create_icon_object(icon_url, creator)
    image_id = CommonsPub.ActivityPub.Utils.maybe_create_image_object(image_url, creator)

    {:ok, updated_actor} =
      case created_actor do
        %CommonsPub.Users.User{} ->
          CommonsPub.Users.update_remote(created_actor, %{icon_id: icon_id, image_id: image_id})

        %CommonsPub.Communities.Community{} ->
          CommonsPub.Communities.update(%CommonsPub.Users.User{}, created_actor, %{
            icon_id: icon_id,
            image_id: image_id
          })

        %CommonsPub.Collections.Collection{} ->
          CommonsPub.Collections.update(%CommonsPub.Users.User{}, created_actor, %{
            icon_id: icon_id,
            image_id: image_id
          })
      end

    object = ActivityPub.Object.get_cached_by_ap_id(actor["id"])

    ActivityPub.Object.update(object, %{pointer_id: created_actor.id})
    Indexer.maybe_index_object(updated_actor)
    {:ok, updated_actor}
  end

  def update_user(actor, data) do
    with params <- %{
           name: data["name"],
           summary: data["summary"],
           icon_id:
             CommonsPub.ActivityPub.Utils.maybe_create_icon_object(
               CommonsPub.ActivityPub.Utils.maybe_fix_image_object(data["icon"]),
               actor
             ),
           image_id:
             CommonsPub.ActivityPub.Utils.maybe_create_image_object(
               CommonsPub.ActivityPub.Utils.maybe_fix_image_object(data["image"]),
               actor
             )
         },
         {:ok, user} <- CommonsPub.Users.update_remote(actor, params) do
      {:ok, user}
    else
      {:error, e} -> {:error, e}
    end
  end

  def update_community(actor, data) do
    with {:ok, creator} <- CommonsPub.Users.one([:default, id: actor.creator_id]),
         params <- %{
           name: data["name"],
           summary: data["summary"],
           icon_id:
             CommonsPub.ActivityPub.Utils.maybe_create_icon_object(
               CommonsPub.ActivityPub.Utils.maybe_fix_image_object(data["icon"]),
               creator
             ),
           image_id:
             CommonsPub.ActivityPub.Utils.maybe_create_image_object(
               CommonsPub.ActivityPub.Utils.maybe_fix_image_object(data["image"]),
               creator
             )
         },
         {:ok, comm} <- CommonsPub.Communities.update(creator, actor, params) do
      {:ok, comm}
    else
      {:error, e} -> {:error, e}
    end
  end

  def update_collection(actor, data) do
    with {:ok, creator} <- CommonsPub.Users.one([:default, id: actor.creator_id]),
         params <- %{
           name: data["name"],
           summary: data["summary"],
           icon_id:
             CommonsPub.ActivityPub.Utils.maybe_create_icon_object(
               CommonsPub.ActivityPub.Utils.maybe_fix_image_object(data["icon"]),
               creator
             )
         },
         {:ok, coll} <- CommonsPub.Collections.update(creator, actor, params) do
      {:ok, coll}
    else
      {:error, e} -> {:error, e}
    end
  end
end
