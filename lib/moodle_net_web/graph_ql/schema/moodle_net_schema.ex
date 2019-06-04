# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.MoodleNetSchema do
  @moduledoc """
  Some common functions used by the resolvers.

  (TODO: The module name should be changed to something better like `ResolverCommon` or `ResolverUtils`.)
  """
  use Absinthe.Schema.Notation

  alias ActivityPub.SQL.{Query}
  alias ActivityPub.Entity

  require ActivityPub.Guards, as: APG
  alias MoodleNetWeb.GraphQL.Errors

  alias MoodleNetWeb.GraphQL.{UserResolver, CommunityResolver}
  alias MoodleNetWeb.GraphQL.{CommentSchema, ActivitySchema}

  @doc """
  Load by id and type
  """
  def resolve_by_id_and_type(type) do
    fn %{local_id: local_id}, info ->
      fields = requested_fields(info)

      case get_by_id_and_type(local_id, type) do
        nil -> {:ok, nil}
        comm -> {:ok, prepare(comm, fields)}
      end
    end
  end

  # Resource

  defp get_by_id_and_type(local_id, type) do
    Query.new()
    |> Query.where(local_id: local_id)
    |> Query.with_type(type)
    |> Query.one()
  end

  def fetch(local_id, type) do
    case get_by_id_and_type(local_id, type) do
      nil -> Errors.not_found_error(local_id, type)
      entity -> {:ok, entity}
    end
  end

  def set_icon(%{icon: url} = attrs) when is_binary(url) do
    Map.put(attrs, :icon, %{type: "Image", url: url})
  end

  def set_icon(attrs), do: attrs

  def set_image(%{image: url} = attrs) when is_binary(url) do
    Map.put(attrs, :image, %{type: "Image", url: url})
  end

  def set_image(attrs), do: attrs

  def set_location(%{location: location} = attrs) when is_binary(location) do
    Map.put(attrs, :location, %{type: "Place", content: location})
  end

  def set_location(attrs), do: attrs

  def set_website(%{website: website} = attrs) when is_binary(website) do
    Map.put(attrs, :attachment, %{type: "PropertyValue", name: "Website", value: website})
  end

  def set_website(attrs), do: attrs

  def current_user(%{context: %{current_user: nil}}), do: Errors.unauthorized_error()
  def current_user(%{context: %{current_user: user}}), do: {:ok, user}

  def current_actor(info) do
    case current_user(info) do
      {:ok, user} ->
        {:ok, user.actor}

      ret ->
        ret
    end
  end

  def prepare(:auth_payload, token, actor, info) do
    user_fields = requested_fields(info, [:me, :user])
    me = prepare(:me, actor, user_fields)
    %{token: token.hash, me: me}
  end

  def prepare(:me, actor, user_fields) do
    user = prepare(actor, user_fields)
    %{email: actor["email"], user: user}
  end

  def prepare([], _), do: []

  @doc """
  Translate from AP notation to MoodleNet API notation

  Loads all the needed `ActivityPub.Aspect`(s) and associations to make the translation.
  """
  def prepare([e | _] = list, fields) when APG.has_type(e, "MoodleNet:Community"),
    do: CommunityResolver.prepare_community(list, fields)

  def prepare(e, fields) when APG.has_type(e, "MoodleNet:Community"),
    do: CommunityResolver.prepare_community(e, fields)

  def prepare([e | _] = list, fields) when APG.has_type(e, "MoodleNet:Collection") do
    list
    |> preload_assoc_cond([:icon], fields)
    |> preload_aspect_cond([:actor_aspect], fields)
    |> Enum.map(&prepare(&1, fields))
  end

  def prepare(e, fields) when APG.has_type(e, "MoodleNet:Collection") do
    e
    |> preload_assoc_cond([:icon], fields)
    |> preload_aspect_cond([:actor_aspect], fields)
    |> prepare_common_fields()
  end

  def prepare([e | _] = list, fields) when APG.has_type(e, "MoodleNet:EducationalResource") do
    list
    |> preload_assoc_cond([:icon], fields)
    |> Enum.map(&prepare(&1, fields))
  end

  def prepare(e, fields) when APG.has_type(e, "MoodleNet:EducationalResource") do
    e
    |> preload_assoc_cond([:icon], fields)
    |> preload_aspect_cond([:resource_aspect], fields)
    |> prepare_common_fields()
  end

  def prepare([e | _] = list, fields) when APG.has_type(e, "Person"),
    do: UserResolver.prepare_user(list, fields)

  def prepare(e, fields) when APG.has_type(e, "Person"),
    do: UserResolver.prepare_user(e, fields)

  def prepare([e | _] = list, fields) when APG.has_type(e, "Note"),
    do: CommentSchema.prepare(list, fields)

  def prepare(e, fields) when APG.has_type(e, "Note"),
    do: CommentSchema.prepare(e, fields)

  def prepare([e | _] = list, fields) when APG.has_type(e, "Activity"),
    do: ActivitySchema.prepare(list, fields)

  def prepare(e, fields) when APG.has_type(e, "Activity"),
    do: ActivitySchema.prepare(e, fields)

  def preload_assoc_cond(entities, assocs, fields) do
    assocs = Enum.filter(assocs, &(to_string(&1) in fields))

    Query.preload_assoc(entities, assocs)
  end

  def preload_aspect_cond(entities, aspects, _fields) do
    # TODO check fields to load aspects conditionally
    Query.preload_aspect(entities, aspects)
  end

  # FIXME add proper resolving to fields with hardcoded values?
  def prepare_common_fields(entity) do
    website = to_website(entity.attachment)

    entity
    |> Map.put(:local_id, Entity.local_id(entity))
    |> Map.put(:local, Entity.local?(entity))
    |> Map.update!(:name, &from_language_value/1)
    |> Map.update!(:content, &from_language_value/1)
    |> Map.update!(:summary, &from_language_value/1)
    |> Map.update!(:url, &List.first/1)
    |> Map.update(:preferred_username, nil, &from_language_value/1)
    |> Map.update(:icon, nil, &to_icon/1)
    |> Map.update(:image, nil, &to_image/1)
    |> Map.update(:location, nil, &to_location/1)
    |> Map.put(:website, website)
    |> Map.put(:followers_count, count_items(entity, :followers))
    |> Map.put(:following_count, 15)
    |> Map.put(:likes_count, entity[:likers_count])
    |> Map.put(:resources_count, 3)
    |> Map.put(:replies_count, 1)
    |> Map.put(:email, entity["email"])
    |> Map.put(:primary_language, entity[:primary_language] || entity["primary_language"])
    |> Map.put(:published, Entity.persistence(entity).inserted_at |> NaiveDateTime.to_iso8601())
    |> Map.put(:updated, Entity.persistence(entity).updated_at |> NaiveDateTime.to_iso8601())
  end

  @doc """
  Transform Natural Language Values to just a simple string
  """
  def from_language_value(string) when is_binary(string), do: string
  def from_language_value(%{"und" => value}), do: value
  def from_language_value(%{}), do: nil
  def from_language_value(_), do: nil

  defp to_icon([entity | _]) when APG.is_entity(entity) do
    with [url | _] <- entity[:url] do
      url
    else
      _ -> nil
    end
  end

  defp to_icon(_), do: nil

  defp to_image([entity | _]) when APG.is_entity(entity) do
    with [url | _] <- entity[:url] do
      url
    else
      _ -> nil
    end
  end

  defp to_image(_), do: nil

  defp to_location([entity | _]) when APG.is_entity(entity) do
    with %{} = content <- entity[:content] do
      from_language_value(content)
    else
      _ -> nil
    end
  end

  defp to_location(_), do: nil

  defp to_website([entity | _]) when APG.is_entity(entity) do
    with website <- entity["value"] do
      website
    else
      _ -> nil
    end
  end

  defp to_website(_), do: nil

  defp count_items(entity, collection) do
    case entity[collection] do
      %ActivityPub.SQL.AssociationNotLoaded{} -> nil
      collection -> collection[:total_items]
    end
  end

  def requested_fields(%Absinthe.Resolution{} = info),
    do: Absinthe.Resolution.project(info) |> Enum.map(& &1.name)

  def requested_fields(%Absinthe.Resolution{} = info, inner_key) when is_atom(inner_key),
    do: requested_fields(info, [inner_key])

  def requested_fields(%Absinthe.Resolution{} = info, inner_keys) when is_list(inner_keys) do
    project = Absinthe.Resolution.project(info)

    Enum.reduce_while(inner_keys, project, fn key, inner ->
      key = to_string(key)

      Enum.find(inner, &(&1.name == key))
      |> case do
        nil -> {:halt, nil}
        inner -> {:cont, Map.fetch!(inner, :selections)}
      end
    end)
    |> case do
      nil ->
        []

      inner ->
        Enum.flat_map(inner, fn
          %Absinthe.Blueprint.Document.Field{} = f ->
            [f.name]

          %Absinthe.Blueprint.Document.Fragment.Inline{} = i ->
            Enum.map(i.selections, & &1.name)
        end)
    end
  end

  @doc """
  Used to resolve many associations. See for example `:joined_communities` in `MoodleNetWeb.GraphQL.UserSchema`.

  The argument passed to this function is the function to be called from the `MoodleNet` module, in this example: `MoodleNet.joined_communities_list/2`.

  When the field `totalCount` is requested in the association, a SQL count query is also performed. See for example how `calculate_connection_count/3` triggers `MoodleNet.joined_communities_count/1`.

  This function handles pagination correctly.

  *FIXME - This function has a 1+n query problem* (example of the problem: load a community list and then for each community perform a separate query to load its members).

  When Alex implemented pagination, he found that the batch middleware used in `with_assoc/2` and pagination didn’t play well together (or just couldn’t make it work). The batch functionality works well when loading all of the association `Entities`, but each `ActivityPub.Entity` has its own id to paginate. We couldn't paginate more than one relation in the same query.

  All this means that every `ActivityPub.Entity` we currently return in GraphQL implies at least one query per `ActivityPub.Entity` in the database.
  """
  def with_connection(method) do
    fn parent, args, info ->
      fields = requested_fields(info)
      entities = calculate_connection_entities(parent, method, args, fields)
      count = calculate_connection_count(parent, method, fields)
      page_info = calculate_connection_page_info(entities, args, fields)

      node_fields = requested_fields(info, [:edges, :node])
      edges = calculate_connection_edges(entities, node_fields)

      {:ok,
       %{
         page_info: page_info,
         edges: edges,
         total_count: count
       }}
    end
  end

  def calculate_connection_count(nil, method, fields) do
    if "totalCount" in fields do
      count_method = String.to_atom("#{method}_count")
      apply(MoodleNet, count_method, [])
    end
  end

  def calculate_connection_count(parent, method, fields) do
    if "totalCount" in fields do
      count_method = String.to_atom("#{method}_count")
      apply(MoodleNet, count_method, [parent])
    end
  end

  defp calculate_connection_entities(nil, method, args, fields) do
    if "pageInfo" in fields || "nodes" in fields do
      list_method = String.to_atom("#{method}_list")
      apply(MoodleNet, list_method, [args])
    end
  end

  defp calculate_connection_entities(parent, method, args, fields) do
    if "pageInfo" in fields || "edges" in fields do
      list_method = String.to_atom("#{method}_list")
      apply(MoodleNet, list_method, [parent, args])
    end
  end

  defp calculate_connection_page_info(nil, _, _), do: nil

  defp calculate_connection_page_info(entities, args, fields) when is_list(entities) do
    if "pageInfo" in fields do
      page_info = MoodleNet.page_info(entities, args)

      %{
        start_cursor: page_info.newer,
        end_cursor: page_info.older
      }
    end
  end

  defp calculate_connection_edges(nil, _), do: nil

  defp calculate_connection_edges(entities, node_fields) do
    entities
    |> prepare(node_fields)
    |> Enum.zip(entities)
    |> Enum.map(fn {node, entity} -> %{cursor: entity.cursor, node: node} end)
  end

  def to_page(method, args, info) do
    fields = requested_fields(info)
    entities = calculate_connection_entities(nil, method, args, fields)
    count = calculate_connection_count(nil, method, fields)
    page_info = calculate_connection_page_info(entities, args, fields)

    node_fields = requested_fields(info, [:nodes])
    nodes = prepare(entities, node_fields)

    {:ok,
     %{
       page_info: page_info,
       nodes: nodes,
       total_count: count
     }}
  end

  def with_assoc(assoc, opts \\ [])

  @doc """
  This function was created before `MoodleNetWeb.GraphQL.MoodleNetSchema.with_connection/1`. It supports “single” and “many” associations. It also used the [batch API](https://hexdocs.pm/absinthe/Absinthe.Middleware.Batch.html).

  This middleware avoids the 1+n query problem (example of the problem: load a community list and then for each community perform a separate query to load its members). This middleware can for example receive a community list and perform a single query to load all their members. But unfortunately it does not seem to play well with pagination.
  """
  def with_assoc(assoc, opts) do
    fn parent, _, info ->
      fields = requested_fields(info)
      preload_args = {assoc, fields}

      args =
        cond do
          Keyword.get(opts, :collection, false) ->
            {__MODULE__, :preload_collection, preload_args}

          Keyword.get(opts, :preload_assoc_individually, false) ->
            {__MODULE__, :preload_assoc_individually, preload_args}

          true ->
            {__MODULE__, :preload_assoc, preload_args}
        end

      batch(
        args,
        parent,
        fn children_map ->
          children =
            children_map[Entity.local_id(parent)]
            |> ensure_single(Keyword.get(opts, :single, false))

          {:ok, children}
        end
      )
    end
  end

  @doc """
  Used to load the `followed` virtual attribute, for example in `MoodleNetWeb.GraphQL.CommunitySchema` (if the `current_user` is following a community this attribute will be true, otherwise false). This function could also be used for `Like` and similar functionalities.
  """
  def with_bool_join(:follow) do
    fn parent, _, info ->
      {:ok, current_actor} = current_actor(info)
      collection_id = ActivityPub.SQL.Common.local_id(current_actor.following)
      args = {__MODULE__, :preload_bool_join, {:follow, collection_id}}

      batch(
        args,
        parent,
        fn children_map ->
          Map.fetch(children_map, Entity.local_id(parent))
        end
      )
    end
  end

  defp ensure_single(children, false), do: children

  defp ensure_single(children, true) do
    case children do
      [] ->
        nil

      [child] ->
        child

      children ->
        raise ArgumentError, "single assoc with more than an object: #{inspect(children)}"
    end
  end

  # It is called from Absinthe
  def preload_assoc_individually({assoc, fields}, parent_list) do
    parent_list = Query.preload_assoc(parent_list, assoc)

    child_list =
      parent_list
      |> Enum.flat_map(&Map.get(&1, assoc))
      |> Enum.uniq_by(&Entity.local_id(&1))

    child_map =
      child_list
      |> Enum.map(&prepare(&1, fields))
      |> Enum.group_by(&Entity.local_id/1)

    Map.new(parent_list, fn parent ->
      children =
        parent
        |> Map.get(assoc)
        |> Enum.map(&Entity.local_id/1)
        |> Enum.flat_map(&child_map[&1])

      {Entity.local_id(parent), children}
    end)
  end

  # It is called from Absinthe
  def preload_assoc({assoc, fields}, parent_list) do
    parent_list = Query.preload_assoc(parent_list, assoc)

    child_list =
      parent_list
      |> Enum.flat_map(&Map.get(&1, assoc))
      |> Enum.uniq_by(&Entity.local_id(&1))

    child_map =
      child_list
      |> prepare(fields)
      |> Enum.group_by(&Entity.local_id/1)

    Map.new(parent_list, fn parent ->
      children =
        parent
        |> Map.get(assoc)
        |> Enum.map(&Entity.local_id/1)
        |> Enum.flat_map(&child_map[&1])

      {Entity.local_id(parent), children}
    end)
  end

  # It is called from Absinthe
  def preload_collection({assoc, fields}, parent_list) do
    parent_list = Query.preload_assoc(parent_list, {assoc, :items})
    [p] = parent_list
    p.followers.items
    child_list = Enum.flat_map(parent_list, &get_in(&1, [assoc, :items]))

    child_map =
      prepare(child_list, fields)
      |> Enum.group_by(&Entity.local_id/1)

    Map.new(parent_list, fn parent ->
      children =
        parent
        |> get_in([assoc, :items])
        |> Enum.map(&Entity.local_id/1)
        |> Enum.flat_map(&child_map[&1])

      {Entity.local_id(parent), children}
    end)
  end

  def preload_bool_join({:follow, collection_id}, parent_list) do
    import Ecto.Query, only: [from: 2]
    parent_ids = Enum.map(parent_list, &Entity.local_id/1)

    ret =
      from(f in "activity_pub_collection_items",
        where: f.subject_id == ^collection_id,
        where: f.target_id in ^parent_ids,
        select: {f.target_id, true}
      )
      |> MoodleNet.Repo.all()
      |> Map.new()

    Enum.reduce(parent_ids, ret, fn id, ret ->
      Map.put_new(ret, id, false)
    end)
  end

  def load_actor(user) do
    Query.new()
    |> Query.preload_aspect(:actor)
    |> Query.where(local_id: user.actor_id)
    |> Query.one()
  end
end
