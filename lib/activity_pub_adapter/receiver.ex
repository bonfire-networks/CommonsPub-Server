defmodule CommonsPub.ActivityPub.Receiver do
  require Logger
  alias CommonsPub.Search.Indexer

  @actor_modules %{
    "Person" => CommonsPub.Users,
    "Group" => CommonsPub.Communities,
    "MN:Collection" => CommonsPub.Collections,
    "Organization" => CommonsPub.Organisations,
    fallback: CommonsPub.Characters
  }
  @activity_modules %{
    "Follow" => CommonsPub.Follows,
    "Like" => CommonsPub.Likes,
    "Flag" => CommonsPub.Flags,
    "Block" => CommonsPub.Blocks,
    "Delete" => CommonsPub.Common.Deletion,
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

  @actor_types Map.keys(@actor_modules) ++
                 [
                   "Person",
                   "Group",
                   "Organization",
                   "Application",
                   "Service",
                   "Community",
                   "MN:Collection",
                   "CommonsPub:Character"
                 ]

  @activity_types Map.keys(@activity_modules)
  @object_types Map.keys(@object_modules)

  IO.inspect(@actor_types)

  @doc """
  load the activity data
  """
  def receive_activity(activity_id) when is_binary(activity_id) do
    activity = ActivityPub.Object.get_by_id(activity_id)

    receive_activity(activity)
  end

  @doc """
  load the object data
  """
  def receive_activity(
        %{
          data: %{
            "object" => object_id
          }
        } = activity
      ) do
    object = CommonsPub.ActivityPub.Utils.get_object_or_actor_by_ap_id!(object_id)

    # IO.inspect(activity: activity)
    # IO.inspect(object: object)

    receive_activity(activity, object)
  end

  # Activity: Update + Object: actor/character
  def receive_activity(
        %{data: %{"type" => "Update"}} = _activity,
        %{data: %{"type" => object_type, "id" => ap_id}} = _object
      )
      when object_type in @actor_types do
    Logger.warn("AP Match#0 - update actor")

    with {:ok, actor} <- ActivityPub.Actor.get_cached_by_ap_id(ap_id),
         {:ok, actor} <- CommonsPub.ActivityPub.Adapter.update_remote_actor(actor) do
      Indexer.maybe_index_object(actor)
      :ok
    end
  end

  def receive_activity(
        %{
          data: %{
            "type" => activity_type
          }
        } = activity,
        %{data: %{"type" => object_type}} = object
      )
      when activity_type in @activity_types and object_type in @object_types do
    Logger.warn(
      "AP Match#1 - by activity_type and object_type: #{activity_type} + #{object_type} = #{
        @activity_modules[activity_type]
      } or #{@object_modules[object_type]}"
    )

    if @activity_modules[activity_type] == @object_modules[object_type] do
      handle_activity_with(
        @activity_modules[activity_type],
        activity,
        object
      )
    else
      Logger.warn(
        "AP Match#1.5 - mismatched activity_type and object_type, try first based on activity, otherwise on object"
      )

      with {:error, e} <-
             handle_activity_with(
               @activity_modules[activity_type],
               activity,
               object
             ),
           {:error, e} <-
             handle_activity_with(
               @object_modules[object_type],
               activity,
               object
             ) do
        {:error, e}
      end
    end
  end

  def receive_activity(
        %{
          data: %{
            "type" => activity_type
          }
        } = activity,
        %{data: %{"type" => object_type}} = object
      )
      when activity_type in @activity_types do
    Logger.warn(
      "AP Match#2 - by activity_type: #{activity_type} + #{object_type} = #{
        @activity_modules[activity_type]
      }"
    )

    handle_activity_with(
      @activity_modules[activity_type],
      activity,
      object
    )
  end

  def receive_activity(
        %{
          data: %{
            "type" => activity_type
          }
        } = activity,
        %{data: %{"type" => object_type}} = object
      )
      when object_type in @object_types do
    Logger.warn(
      "AP Match#3 - by object_type: #{activity_type} + #{object_type} = #{
        @object_modules[object_type]
      }"
    )

    handle_activity_with(
      @object_modules[object_type],
      activity,
      object
    )
  end

  def receive_activity(
        %{
          data: %{
            "type" => activity_type
          }
        } = activity,
        object
      )
      when activity_type in @activity_types do
    Logger.warn(
      "AP Match#4 - Only activity_type known: #{activity_type} = #{
        @activity_modules[activity_type]
      }"
    )

    handle_activity_with(
      @activity_modules[activity_type],
      activity,
      object
    )
  end

  def receive_activity(activity, object) do
    # for cases when the object comes to us embeded in the activity
    receive_activity(activity, %{data: object})
  end

  def receive_activity(activity, object) do
    error = "ActivityPub - ignored incoming activity - unhandled activity or object type"
    Logger.warn("#{error}")
    Logger.warn("activity: #{inspect(activity)}")
    Logger.warn("object: #{inspect(object)}")
    {:error, error}
  end

  def handle_activity_with(module, activity, object) do
    CommonsPub.Contexts.run_context_function(
      module,
      :ap_receive_activity,
      [activity, object]
    )
  end

  # TODO: Rewrite this whole thing tbh
  def create_remote_character(actor, username) do
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
            CommonsPub.ActivityPub.Utils.get_raw_character_by_ap_id(actor["attributedTo"])

          {:ok, created_actor} = CommonsPub.Communities.create_remote(creator, create_attrs)
          {:ok, created_actor, creator}

        "MN:Collection" ->
          {:ok, creator} =
            CommonsPub.ActivityPub.Utils.get_raw_character_by_ap_id(actor["attributedTo"])

          {:ok, community} =
            CommonsPub.ActivityPub.Utils.get_raw_character_by_ap_id(actor["context"])

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
end
