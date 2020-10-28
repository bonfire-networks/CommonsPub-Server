defmodule CommonsPub.ActivityPub.Receiver do
  require Logger
  alias CommonsPub.ActivityPub.Utils
  alias CommonsPub.Search.Indexer

  @actor_modules %{
    "Person" => CommonsPub.Users,
    "Group" => CommonsPub.Communities,
    "MN =>Collection" => CommonsPub.Collections,
    "Organization" => CommonsPub.Organisations,
    fallback: CommonsPub.Characters
  }
  @activity_modules %{
    "Follow" => CommonsPub.Follows,
    "Like" => CommonsPub.Likes,
    "Flag" => CommonsPub.Flags,
    "Block" => CommonsPub.Blocks,
    fallback: CommonsPub.Activities
  }
  @object_modules %{
    "Note" => CommonsPub.Threads.Comments,
    "Document" => CommonsPub.Resources,
    "Follow" => CommonsPub.Follows,
    "Like" => CommonsPub.Likes,
    "Flag" => CommonsPub.Flags,
    "Block" => CommonsPub.Blocks
  }

  @actor_types Map.keys(@actor_modules)
  @activity_types Map.keys(@activity_modules)
  @object_types Map.keys(@object_modules)

  def perform(
        :handle_activity,
        %{
          data: %{
            "type" => activity_type,
            "object" => %{"type" => object_type}
          }
        } = activity
      )
      when activity_type in @activity_types and object_type in @object_types do
    Logger.warn("Match#1 - by activity_type and object_type - #{activity_type} #{object_type}")

    if @activity_modules[activity_type] == @object_modules[object_type] do
      handle_activity(
        @activity_modules[activity_type],
        activity
      )
    else
      # TODO
      {:error,
       "TBD: Which of the object or activity type preferred module should take precedence?"}
    end
  end

  def perform(
        :handle_activity,
        %{
          data: %{
            "type" => activity_type,
            "object" => %{"type" => object_type}
          }
        } = activity
      )
      when activity_type in @activity_types do
    Logger.warn("Match#2 - by activity_type - #{activity_type} #{object_type} ")

    handle_activity(
      @activity_modules[activity_type],
      activity
    )
  end

  def perform(
        :handle_activity,
        %{
          data: %{
            "type" => activity_type,
            "object" => %{"type" => object_type}
          }
        } = activity
      )
      when object_type in @object_types do
    Logger.warn("Match#3 - by object_type - #{activity_type} #{object_type}")

    handle_activity(
      @object_modules[object_type],
      activity
    )
  end

  def perform(
        :handle_activity,
        %{
          data: %{
            "type" => activity_type,
            "object" => object_id
          }
        } = activity
      )
      when is_binary(object_id) do
    Logger.warn("Match#4 - need to load object first - #{activity_type} #{object_id} ")

    object = ActivityPub.Object.get_cached_by_ap_id(object_id)

    activity =
      Map.merge(activity, %{
        data: %{
          "object" => object
        }
      })

    IO.inspect(new_activity: activity)

    perform(
      :handle_activity,
      activity
    )

    # handle_create(activity, object)
  end

  def perform(:handle_activity, activity, object \\ nil)

  def perform(
        :handle_activity,
        %{
          data: %{
            "type" => activity_type
          }
        } = activity
      )
      when activity_type in @activity_types do
    Logger.warn("Match#5 - Only activity_type known - #{activity_type} ")

    handle_activity(
      @activity_modules[activity_type],
      activity
    )
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
    error = "ActivityPub - ignored incoming activity - unhandled activity type"
    Logger.warn("#{error} #{inspect(activity)}")
    {:error, error}
  end

  def handle_activity(module, activity) do
    CommonsPub.Contexts.run_context_function(
      module,
      :ap_receive_activity,
      activity
    )
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
