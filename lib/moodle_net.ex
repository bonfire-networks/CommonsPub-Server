# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet do
  @moduledoc """
  Contains many functions for MoodleNet

  FIXME - many preload of aspects and assocs for `to` property.
  It probably can be optimized or paralelized in a better way.

  TODO - move some of these functions to more approriate modules, including into `ActivityPub` for those that aren't MoodleNet-specific.

  """
  import ActivityPub.Guards
  alias ActivityPub.SQL.{Query, Alter}

  alias MoodleNet.Policy
  require ActivityPub.Guards, as: APG

  @doc """
  User connections
  """
  def joined_communities_query(actor) do
    Query.new()
    |> Query.with_type("MoodleNet:Community")
    |> Query.belongs_to(:following, actor)
  end

  def joined_communities_list(actor, opts \\ %{}) do
    joined_communities_query(actor)
    |> Query.paginate_collection(opts)
    |> Query.all()
  end

  def joined_communities_count(actor) do
    joined_communities_query(actor)
    |> Query.count()
  end

  defp following_collection_query(actor) do
    Query.new()
    |> Query.with_type("MoodleNet:Collection")
    |> Query.belongs_to(:following, actor)
  end

  def following_collection_list(actor, opts \\ %{}) do
    following_collection_query(actor)
    |> Query.paginate_collection(opts)
    |> Query.all()
  end

  def following_collection_count(actor) do
    following_collection_query(actor)
    |> Query.count()
  end


  @doc """
  Actor Outbox (eg. user's activities)
  """
  def outbox_query(actor) do
    Query.new()
    |> Query.with_type("Activity")
    |> Query.without_type("Undo")
    |> Query.belongs_to(:outbox, actor)
  end

  @doc """
  Actor Inbox (eg. user's timeline of activities from followed actors)
  """
  def inbox_query(actor) do
    Query.new()
    |> Query.with_type("Activity")
    |> Query.without_type("Undo")
    |> Query.belongs_to(:inbox, actor)
  end

  @doc """
  Community connections
  """
  def community_inbox_list(community, opts) do
    inbox_query(community)
    |> Query.paginate(opts)
    |> Query.all()
  end

  def community_inbox_count(community) do
    inbox_query(community)
    |> Query.count()
  end

  defp community_thread_query(community) do
    Query.new()
    |> Query.belongs_to(:threads, community)
  end

  def community_thread_list(community, opts \\ %{}) do
    community_thread_query(community)
    |> Query.paginate(opts)
    |> Query.all()
  end

  def community_thread_count(community) do
    community_thread_query(community)
    |> Query.count()
  end

  def community_list(opts \\ %{}) do
    Query.new()
    |> Query.with_type("MoodleNet:Community")
    |> Query.paginate(opts)
    |> Query.all()
  end

  def community_count() do
    Query.new()
    |> Query.with_type("MoodleNet:Community")
    |> Query.count()
  end

  def community_collection_query(community) do
    Query.new()
    |> Query.with_type("MoodleNet:Collection")
    |> Query.has(:context, community)
  end

  def community_collection_list(community, opts \\ %{}) do
    community_collection_query(community)
    |> Query.paginate(opts)
    |> Query.all()
  end

  def community_collection_count(community) do
    community_collection_query(community)
    |> Query.count()
  end


  @doc """
  Collection connections
  """
  def collection_inbox_list(collection, opts) do
    inbox_query(collection)
    |> Query.paginate(opts)
    |> Query.all()
  end

  def collection_inbox_count(collection) do
    inbox_query(collection)
    |> Query.count()
  end

  def collection_list(opts \\ %{}) do
    Query.new()
    |> Query.with_type("MoodleNet:Collection")
    |> Query.paginate(opts)
    |> Query.all()
  end

  def collection_count() do
    Query.new()
    |> Query.with_type("MoodleNet:Collection")
    |> Query.count()
  end

  defp collection_follower_query(collection) do
    Query.new()
    |> Query.with_type("Person")
    |> Query.belongs_to(:followers, collection)
  end

  def collection_follower_list(collection, opts \\ %{}) do
    collection_follower_query(collection)
    |> Query.paginate_collection(opts)
    |> Query.all()
  end

  def collection_follower_count(collection) do
    collection_follower_query(collection)
    |> Query.count()
  end

  defp collection_resource_query(collection) do
    Query.new()
    |> Query.with_type("MoodleNet:EducationalResource")
    |> Query.has(:context, collection)
  end

  def collection_resource_list(collection, opts \\ %{}) do
    collection_resource_query(collection)
    |> Query.paginate_collection(opts)
    |> Query.all()
  end

  def collection_resource_count(collection) do
    collection_resource_query(collection)
    |> Query.count()
  end

  defp collection_thread_query(collection) do
    Query.new()
    |> Query.belongs_to(:threads, collection)
  end

  def collection_thread_list(collection, opts \\ %{}) do
    collection_thread_query(collection)
    |> Query.paginate(opts)
    |> Query.all()
  end

  def collection_thread_count(collection) do
    collection_thread_query(collection)
    |> Query.count()
  end

  defp collection_liker_query(collection) do
    Query.new()
    |> Query.with_type("Person")
    |> Query.belongs_to(:likers, collection)
  end

  def collection_liker_list(collection, opts \\ %{}) do
    collection_liker_query(collection)
    |> Query.paginate_collection(opts)
    |> Query.all()
  end

  def collection_liker_count(collection) do
    collection_liker_query(collection)
    |> Query.count()
  end


  @doc """
  Resource connections
  """
  def resource_liker_query(resource) do
    Query.new()
    |> Query.with_type("Person")
    |> Query.belongs_to(:likers, resource)
  end

  def resource_liker_list(resource, opts \\ %{}) do
    resource_liker_query(resource)
    |> Query.paginate_collection(opts)
    |> Query.all()
  end

  def resource_liker_count(resource) do
    resource_liker_query(resource)
    |> Query.count()
  end


  @doc """
  Comment connections
  """
  def comment_liker_query(comment) do
    Query.new()
    |> Query.with_type("Person")
    |> Query.belongs_to(:likers, comment)
  end

  def comment_liker_list(comment, opts \\ %{}) do
    comment_liker_query(comment)
    |> Query.paginate_collection(opts)
    |> Query.all()
  end

  def comment_liker_count(comment) do
    comment_liker_query(comment)
    |> Query.count()
  end

  defp comment_reply_query(comment) do
    Query.new()
    |> Query.with_type("Note")
    |> Query.has(:in_reply_to, comment)
  end

  def comment_reply_list(comment, opts \\ %{}) do
    comment_reply_query(comment)
    |> Query.paginate_collection(opts)
    |> Query.all()
  end

  def comment_reply_count(comment) do
    comment_reply_query(comment)
    |> Query.count()
  end


  @doc """
  Activities
  """
  def local_activity_list(opts \\ %{}) do
    Query.new()
    |> Query.with_type("Activity")
    |> Query.without_type("Undo")
    |> Query.preload_aspect(:activity)
    |> Query.paginate(opts)
    |> Query.all()
  end

  def local_activity_count() do
    Query.new()
    |> Query.with_type("Activity")
    |> Query.without_type("Undo")
    |> Query.count()
  end

  def page_info(results, opts) do
    ActivityPub.SQL.Paginate.meta(results, opts)
  end

  def user_outbox_list(user, opts) do
    outbox_query(user)
    |> Query.paginate(opts)
    |> Query.all()
  end

  def user_outbox_count(user) do
    outbox_query(user)
    |> Query.count()
  end

  def user_inbox_list(user, opts) do
    inbox_query(user)
    |> Query.paginate(opts)
    |> Query.all()
  end

  def user_inbox_count(user) do
    inbox_query(user)
    |> Query.count()
  end

  defp user_comment_query(actor) do
    Query.new()
    |> Query.with_type("Note")
    |> Query.has(:attributed_to, actor)
  end

  def user_comment_list(actor, opts \\ %{}) do
    user_comment_query(actor)
    |> Query.paginate(opts)
    |> Query.all()
  end

  def user_comment_count(actor) do
    user_comment_query(actor)
    |> Query.count()
  end

  defp community_member_query(community) do
    Query.new()
    |> Query.with_type("Person")
    |> Query.has(:following, community)

    # |> Query.belongs_to(:followers, community)
  end

  def community_member_list(community, opts \\ %{})
      when APG.has_type(community, "MoodleNet:Community") do
    community_member_query(community)
    |> Query.paginate_collection(opts)
    |> Query.all()
  end

  def community_member_count(community)
      when APG.has_type(community, "MoodleNet:Community") do
    community_member_query(community)
    |> Query.count()
  end

  def create_community(actor, attrs) do
    attrs =
      attrs
      |> Map.put("type", "MoodleNet:Community")
      |> Map.put("attributed_to", actor)

    activity = %{
      "type" => "Create",
      "actor" => actor,
      "to" => Query.preload(actor.followers),
      "_public" => true
    }

    with {:ok, community} <- ActivityPub.new(attrs),
         activity = Map.put(activity, "object", community),
         {:ok, activity} <- ActivityPub.new(activity),
         {:ok, %{object: [community]}} <- ActivityPub.apply(activity),
         {:ok, true} <- MoodleNet.join_community(actor, community) do
      {:ok, community}
    end
  end

  def update_community(actor, community, changes) do
    community =
      Query.preload_assoc(community, :icon)
      |> Query.preload_aspect(:actor)

    icon = List.first(community.icon)
    {icon_url, changes} = Map.pop(changes, :icon, :no_change)

    activity = %{
      "type" => "Update",
      "actor" => actor,
      "object" => community,
      "to" => [community, Query.preload(community.followers), Query.preload(actor.followers)],
      "_changes" => changes
    }

    # FIXME this should be a transaction
    with {:ok, _icon} <- update_icon(icon, icon_url),
         {:ok, community} <- update_object(activity),
         do: {:ok, community |> Query.reload() |> Query.preload_assoc([:icon])}
  end

  defp update_object(%{object: [object], _changes: params}) when params == %{}, do: {:ok, object}

  defp update_object(activity) do
    with {:ok, activity} <- ActivityPub.new(activity),
         {:ok, %{object: [obj]}} <- ActivityPub.apply(activity),
         do: {:ok, obj}
  end

  defp update_icon(icon, :no_change), do: {:ok, icon}

  defp update_icon(icon, nil) do
    ActivityPub.delete(icon)
    {:ok, nil}
  end

  defp update_icon(icon, icon_url), do: ActivityPub.update(icon, url: icon_url)

  def delete_community(_actor, community) do
    # FIXME this should be a transaction
    Query.new()
    |> Query.with_type("Note")
    |> Query.has(:context, community)
    |> Query.delete_all()

    community_local_id = ActivityPub.Entity.local_id(community)

    import Ecto.Query, only: [from: 2]

    from(entity in ActivityPub.SQLEntity,
      where: fragment("? @> array['MoodleNet:EducationalResource']", entity.type),
      join: collection_context in "activity_pub_object_contexts",
      on: collection_context.subject_id == entity.local_id,
      join: community_context in "activity_pub_object_contexts",
      on:
        collection_context.target_id == community_context.subject_id and
          community_context.target_id == ^community_local_id
    )
    |> MoodleNet.Repo.delete_all()

    from(entity in ActivityPub.SQLEntity,
      where: fragment("? @> array['Note']", entity.type),
      join: collection_context in "activity_pub_object_contexts",
      on: collection_context.subject_id == entity.local_id,
      join: community_context in "activity_pub_object_contexts",
      on:
        collection_context.target_id == community_context.subject_id and
          community_context.target_id == ^community_local_id
    )
    |> MoodleNet.Repo.delete_all()

    Query.new()
    |> Query.with_type("MoodleNet:Collection")
    |> Query.has(:context, community)
    |> Query.delete_all()

    ActivityPub.delete(community, [:icon])
    :ok
  end

  def create_collection(actor, community, attrs)
      when has_type(community, "MoodleNet:Community") do
    attrs =
      attrs
      |> Map.put(:type, "MoodleNet:Collection")
      |> Map.put(:attributed_to, [actor])
      |> Map.put(:context, [community])

    community = Query.preload_aspect(community, :actor)

    activity = %{
      "type" => "Create",
      "actor" => actor,
      "to" => [community, Query.preload(community.followers), Query.preload(actor.followers)],
      "_public" => true
    }

    with :ok <- Policy.create_collection?(actor, community, attrs),
         {:ok, collection} <- ActivityPub.new(attrs),
         activity = Map.put(activity, "object", collection),
         {:ok, activity} <- ActivityPub.new(activity),
         {:ok, %{object: [collection]}} <- ActivityPub.apply(activity),
         {:ok, 1} <- Alter.add(community, :collections, collection),
         {:ok, true} <- MoodleNet.follow_collection(actor, collection) do
      {:ok, collection}
    end
  end

  def update_collection(actor, collection, changes = %{})
      when has_type(actor, "Person") and has_type(collection, "MoodleNet:Collection") do
    collection =
      Query.preload_assoc(collection, [:icon, context: {[:actor], [:followers]}])
      |> Query.preload_aspect(:actor)

    [community] = collection.context

    icon = List.first(collection.icon)
    {icon_url, changes} = Map.pop(changes, :icon, :no_change)

    activity = %{
      "type" => "Update",
      "actor" => actor,
      "_public" => true,
      "object" => collection,
      "to" => [
        community,
        collection,
        community.followers,
        Query.preload(collection.followers),
        Query.preload(actor.followers)
      ],
      "_changes" => changes
    }

    # FIXME this should be a transaction
    with {:ok, _icon} <- update_icon(icon, icon_url),
         {:ok, collection} <- update_object(activity),
         do: {:ok, collection |> Query.reload() |> Query.preload_assoc([:icon])}
  end

  def delete_collection(_actor, collection) do
    # FIXME this should be a transaction
    Query.new()
    |> Query.with_type("Note")
    |> Query.has(:context, collection)
    |> Query.delete_all()

    Query.new()
    |> Query.with_type("MoodleNet:EducationalResource")
    |> Query.has(:context, collection)
    |> Query.delete_all()

    ActivityPub.delete(collection, [:icon])
    :ok
  end

  def create_resource(actor, collection, attrs)
      when has_type(collection, "MoodleNet:Collection") do
    collection = Query.preload_assoc(collection, [:followers, context: :followers])
    [community] = collection.context

    attrs =
      attrs
      |> Map.put(:type, "MoodleNet:EducationalResource")
      |> Map.put(:attributed_to, [actor])
      |> Map.put(:context, [collection])

    activity = %{
      "type" => "Create",
      "actor" => actor,
      "to" => [
        community,
        collection,
        community.followers,
        collection.followers,
        Query.preload(actor.followers)
      ],
      "_public" => true
    }

    with :ok <- Policy.create_resource?(actor, collection, attrs),
         {:ok, resource} <- ActivityPub.new(attrs),
         activity = Map.put(activity, "object", resource),
         {:ok, activity} <- ActivityPub.new(activity),
         {:ok, %{object: [resource]}} <- ActivityPub.apply(activity),
         {:ok, 1} <- Alter.add(collection, :resources, resource) do
      {:ok, resource}
    end
  end

  def update_resource(actor, resource, changes) do
    resource =
      Query.preload_assoc(resource, [
        :icon,
        context: {[:actor], [context: {[:actor], []}]}
      ])

    %{context: [collection]} = resource
    %{context: [community]} = collection

    icon = List.first(resource.icon)
    {icon_url, changes} = Map.pop(changes, :icon, :no_change)

    activity = %{
      "type" => "Update",
      "actor" => actor,
      "object" => resource,
      "to" => [
        community,
        collection,
        Query.preload(community.followers),
        Query.preload(collection.followers),
        Query.preload(actor.followers)
      ],
      "_changes" => changes
    }

    # FIXME this should be a transaction
    with {:ok, _icon} <- update_icon(icon, icon_url),
         {:ok, _resource} <- update_object(activity),
         do: {:ok, resource |> Query.reload() |> Query.preload_assoc([:icon])}
  end

  def delete_resource(_actor, resource) do
    ActivityPub.delete(resource, [:icon])
    :ok
  end

  def copy_resource(actor, resource, collection) do
    resource =
      resource
      |> Query.preload_aspect(:resource)
      |> Query.preload_assoc([:icon])

    attrs =
      Map.take(resource, [
        :name,
        :summary,
        :content,
        :url,
        :primary_language,
        :icon,
        :published,
        :updated,
        :same_as,
        :in_language,
        :public_access,
        :is_accesible_for_free,
        :license,
        :learning_resource_type,
        :educational_use,
        :time_required,
        :typical_age_range
      ])

    url = get_in(resource, [:icon, Access.at(0), :url])
    attrs = Map.put(attrs, :icon, %{type: "Image", url: url})
    create_resource(actor, collection, attrs)
  end

  def create_thread(author, context, attrs)
      when has_type(author, "Person") and has_type(context, "MoodleNet:Community")
      when has_type(author, "Person") and has_type(context, "MoodleNet:Collection") do
    context =
      preload_community(context)
      |> Query.preload_assoc(:followers)

    ret =
      attrs
      |> Map.put(:context, [context])
      |> Map.put(:attributed_to, [author])
      |> create_comment()

    with {:ok, comment} <- ret,
         {:ok, 1} <- Alter.add(context, :threads, comment),
         do: ret
  end

  def create_reply(author, in_reply_to, attrs)
      when has_type(author, "Person") and has_type(in_reply_to, "Note") do
    context =
      Query.new()
      |> Query.belongs_to(:context, in_reply_to)
      |> Query.one()
      |> preload_community()
      |> Query.preload_assoc(:followers)

    in_reply_to = Query.preload_assoc(in_reply_to, :attributed_to)

    attrs
    |> Map.put(:context, [context])
    |> Map.put(:in_reply_to, in_reply_to)
    |> Map.put(:attributed_to, [author])
    |> create_comment()
  end

  defp create_comment(attrs) do
    attrs = attrs |> Map.put("type", "Note")
    [context] = attrs[:context]
    [actor] = attrs[:attributed_to]

    to =
      if reply_to = attrs[:in_reply_to] do
        [in_reply_to_author] = reply_to.attributed_to
        [in_reply_to_author, context, context.followers, Query.preload(actor.followers)]
      else
        [context, context.followers, Query.preload(actor.followers)]
      end

    activity = %{
      "type" => "Create",
      "actor" => actor,
      "to" => to,
      "_public" => true
    }

    with :ok <- Policy.create_comment?(actor, context, attrs),
         {:ok, comment} <- ActivityPub.new(attrs),
         activity = Map.put(activity, "object", comment),
         {:ok, activity} <- ActivityPub.new(activity),
         {:ok, %{object: [comment]}} <- ActivityPub.apply(activity) do
      {:ok, comment}
    end
  end

  def delete_comment(actor, comment) do
    if Query.has?(comment, :attributed_to, actor) do
      ActivityPub.delete(comment)
    else
      {:error, :forbidden}
    end
  end

  def join_community(actor, community)
      when has_type(actor, "Person") and has_type(community, "MoodleNet:Community") do
    community = Query.preload_aspect(community, :actor)

    params = %{
      type: "Follow",
      actor: actor,
      object: community,
      to: [community, Query.preload(actor.followers), Query.preload(community.followers)]
    }

    with {:ok, activity} = ActivityPub.new(params),
         {:ok, _activity} <- ActivityPub.apply(activity) do
      {:ok, true}
    end
  end

  def follow_collection(actor, collection)
      when has_type(actor, "Person") and has_type(collection, "MoodleNet:Collection") do
    collection = Query.preload_assoc(collection, [:followers, context: :followers])
    [community] = collection.context

    params = %{
      type: "Follow",
      actor: actor,
      object: collection,
      to: [collection, collection.followers, community.followers, Query.preload(actor.followers)]
    }

    with {:ok, activity} = ActivityPub.new(params),
         {:ok, _activity} <- ActivityPub.apply(activity) do
      {:ok, true}
    end
  end

  def like_comment(actor, comment)
      when has_type(actor, "Person") and has_type(comment, "Note") do
    comment =
      comment
      |> Query.preload_assoc([:attributed_to, context: [:followers, :context]])

    [attributed_to] = comment.attributed_to
    actor = Query.preload_assoc(actor, :followers)
    [context] = comment.context

    attrs = %{
      type: "Like",
      _public: true,
      actor: actor,
      object: comment,
      to: [actor.followers, attributed_to, context, context.followers]
    }

    with :ok <- Policy.like_comment?(actor, comment, attrs),
         {:ok, activity} = ActivityPub.new(attrs),
         {:ok, _activity} <- ActivityPub.apply(activity) do
      {:ok, true}
    end
  end

  def like_collection(actor, collection)
      when has_type(actor, "Person") and has_type(collection, "MoodleNet:Collection") do
    collection =
      Query.preload_assoc(collection, [:followers, context: [:followers]])
      |> Query.preload_aspect(:actor)

    [community] = collection.context

    attrs = %{
      type: "Like",
      actor: actor,
      object: collection,
      to: [Query.preload(actor.followers), collection, collection.followers, community.followers]
    }

    with :ok <- Policy.like_collection?(actor, collection, attrs),
         {:ok, activity} = ActivityPub.new(attrs),
         {:ok, _activity} <- ActivityPub.apply(activity) do
      {:ok, true}
    end
  end

  def like_resource(actor, resource)
      when has_type(actor, "Person") and has_type(resource, "MoodleNet:EducationalResource") do
    resource = preload_community(resource)
    [collection] = resource.context

    attrs = %{
      type: "Like",
      actor: actor,
      object: resource,
      to: [collection, Query.preload(collection.followers), Query.preload(actor.followers)]
    }

    with :ok <- Policy.like_resource?(actor, resource, attrs),
         {:ok, activity} = ActivityPub.new(attrs),
         {:ok, _activity} <- ActivityPub.apply(activity) do
      {:ok, true}
    end
  end

  def like(liker, liked) do
    params = %{type: "Like", actor: liker, object: liked}

    with {:ok, activity} = ActivityPub.new(params),
         {:ok, _activity} <- ActivityPub.apply(activity) do
      {:ok, true}
    end
  end

  def undo_follow(follower, following) do
    with :ok <- find_current_relation(follower, :following, following),
         {:ok, follow} <- find_activity("Follow", follower, following),
         params = %{type: "Undo", actor: follower, object: follow, to: following, _public: true},
         {:ok, activity} = ActivityPub.new(params),
         {:ok, _activity} <- ActivityPub.apply(activity) do
      {:ok, true}
    end
  end

  def undo_like(liker, liked) do
    liked = undo_like_preload_liked(liked)

    with :ok <- find_current_relation(liker, :liked, liked),
         {:ok, like} <- find_activity("Like", liker, liked),
         to <- calc_undo_like_to(liked),
         params = %{type: "Undo", actor: liker, object: like, to: to, _public: true},
         {:ok, activity} <- ActivityPub.new(params),
         {:ok, _activity} <- ActivityPub.apply(activity) do
      {:ok, true}
    end
  end

  defp undo_like_preload_liked(comment) when has_type(comment, "Note"),
    do: Query.preload_assoc(comment, [:attributed_to, context: {[:actor], [:context]}])

  defp undo_like_preload_liked(resource) when has_type(resource, "MoodleNet:EducationalResource"),
    do: Query.preload_assoc(resource, [:attributed_to, context: {[:actor], [:context]}])

  defp undo_like_preload_liked(collection) when has_type(collection, "MoodleNet:Collection"),
    do: Query.preload_assoc(collection, context: {[:actor], []})

  defp calc_undo_like_to(comment) when has_type(comment, "Note") do
    [author] = comment.attributed_to
    [author, get_community(comment)]
  end

  defp calc_undo_like_to(resource) when has_type(resource, "MoodleNet:EducationalResource") do
    [author] = resource.attributed_to
    [author, get_community(resource)]
  end

  defp calc_undo_like_to(collection) when has_type(collection, "MoodleNet:Collection"),
    do: [collection, get_community(collection)]

  defp find_current_relation(subject, relation, object) do
    if Query.has?(subject, relation, object) do
      :ok
    else
      subject_id = ActivityPub.Entity.local_id(subject)
      object_id = ActivityPub.Entity.local_id(object)
      {:error, {:not_found, [subject_id, object_id], "Activity"}}
    end
  end

  defp find_activity(type, actor, object) do
    Query.new()
    |> Query.with_type(type)
    |> Query.has(:actor, actor)
    |> Query.has(:object, object)
    |> Query.last()
    |> case do
      nil ->
        actor_id = ActivityPub.Entity.local_id(actor)
        object_id = ActivityPub.Entity.local_id(object)
        {:error, {:not_found, [actor_id, object_id], "Activity"}}

      activity ->
        activity = Query.preload_assoc(activity, actor: {[:actor], []}, object: {[:actor], []})
        {:ok, activity}
    end
  end

  defp preload_community(community) when has_type(community, "MoodleNet:Community"),
    do: community

  defp preload_community(collection) when has_type(collection, "MoodleNet:Collection"),
    do: Query.preload_assoc(collection, :context)

  defp preload_community(resource) when has_type(resource, "MoodleNet:EducationalResource") do
    Query.preload_assoc(resource, context: {[:actor], [:context]})
  end

  defp preload_community(comment) when has_type(comment, "Note") do
    Query.preload_assoc(comment, context: {[:actor], [:context]})
  end

  def get_community(comment) when has_type(comment, "Note") do
    [context] = comment.context
    get_community(context)
  end

  def get_community(resource) when has_type(resource, "MoodleNet:EducationalResource") do
    [collection] = resource.context
    get_community(collection)
  end

  def get_community(collection) when has_type(collection, "MoodleNet:Collection") do
    [community] = collection.context
    community
  end

  def get_community(community) when has_type(community, "MoodleNet:Community"), do: community
end
