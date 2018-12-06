defmodule MoodleNetWeb.GraphQL.MoodleNetSchema do
  use Absinthe.Schema.Notation

  alias ActivityPub.SQL.{Query}
  alias ActivityPub.Entity

  require ActivityPub.Guards, as: APG

  object :auth_payload do
    field(:token, :string)
    field(:me, :me)
  end

  object :me do
    field(:id, :id)
    field(:local_id, :string)
    field(:local, :boolean)
    field(:type, list_of(:string))
    field(:preferred_username, :string)
    field(:name, :string)
    field(:summary, :string)
    field(:location, :string)
    field(:icon, :string)
    field(:primary_language, :string)
    field(:email, :string)

    field(:comments, non_null(list_of(non_null(:comment))),
      do: resolve(with_assoc(:attributed_to_inv))
    )
  end

  object :user do
    field(:id, :id)
    field(:local_id, :string)
    field(:local, :boolean)
    field(:type, list_of(:string))
    field(:preferred_username, :string)
    field(:name, :string)
    field(:summary, :string)
    field(:location, :string)
    field(:icon, :string)
    field(:primary_language, :string)

    field(:comments, non_null(list_of(non_null(:comment))),
      do: resolve(with_assoc(:attributed_to_inv))
    )
  end

  input_object :user_input do
    field(:email, non_null(:string))
    field(:password, non_null(:string))
    field(:preferred_username, non_null(:string))
    field(:name, :string)
    field(:summary, :string)
    field(:location, :string)
    field(:icon, :string)
    field(:primary_language, :string)
  end

  input_object :login_input do
    field(:email, non_null(:string))
    field(:password, non_null(:string))
  end

  object :community do
    field(:id, :string)
    field(:local_id, :id)
    field(:local, :boolean)
    field(:type, list_of(:string))

    field(:name, :string)
    field(:content, :string)
    field(:summary, :string)

    field(:preferred_username, :string)

    field(:following_count, :integer)
    field(:followers_count, :integer)

    field(:icon, :string)

    field(:primary_language, :string)

    field(:collections_count, :integer)

    field(:collections, non_null(list_of(non_null(:collection))),
      do: resolve(with_assoc(:attributed_to_inv))
    )

    field(:comments, non_null(list_of(non_null(:comment))), do: resolve(with_assoc(:context_inv)))

    field(:published, :string)
    field(:updated, :string)
  end

  input_object :community_input do
    field(:name, non_null(:string))
    field(:content, non_null(:string))
    field(:summary, non_null(:string))
    field(:preferred_username, non_null(:string))
    field(:icon, :string)
    field(:primary_language, :string)
  end

  object :collection do
    field(:id, :string)
    field(:local_id, :id)
    field(:local, :boolean)
    field(:type, list_of(:string))

    field(:name, :string)
    field(:content, :string)
    field(:summary, :string)

    field(:preferred_username, :string)

    field(:following_count, :integer)
    field(:followers_count, :integer)

    field(:icon, :string)

    field(:primary_language, :string)
    field(:resources_count, :integer)

    field(:resources, non_null(list_of(non_null(:resource))),
      do: resolve(with_assoc(:attributed_to_inv))
    )

    field(:comments, non_null(list_of(non_null(:comment))), do: resolve(with_assoc(:context_inv)))

    field(:communities, non_null(list_of(non_null(:community))),
      do: resolve(with_assoc(:attributed_to))
    )

    field(:published, :string)
    field(:updated, :string)
  end

  input_object :collection_input do
    field(:name, non_null(:string))
    field(:content, non_null(:string))
    field(:summary, non_null(:string))
    field(:preferred_username, non_null(:string))
    field(:icon, :string)
    field(:primary_language, :string)
  end

  object :resource do
    field(:id, :string)
    field(:local_id, :id)
    field(:local, :boolean)
    field(:type, list_of(:string))

    field(:name, :string)
    field(:content, :string)
    field(:summary, :string)

    field(:icon, :string)

    field(:primary_language, :string)
    field(:likes_count, :integer)
    field(:url, :string)

    field(:collections, non_null(list_of(non_null(:collection))),
      do: resolve(with_assoc(:attributed_to))
    )

    field(:published, :string)
    field(:updated, :string)
  end

  input_object :resource_input do
    field(:id, :string)
    field(:local_id, :id)
    field(:local, :boolean)
    field(:type, list_of(:string))
    field(:name, :string)
    field(:content, :string)
    field(:summary, :string)
    field(:icon, :string)
    field(:primary_language, :string)
    field(:url, :string)
  end

  object :comment do
    field(:id, :string)
    field(:local_id, :id)
    field(:local, :boolean)
    field(:type, list_of(:string))

    field(:content, :string)
    field(:likes_count, :integer)
    field(:replies_count, :integer)
    field(:published, :string)
    field(:updated, :string)

    field(:author, :user, do: resolve(with_assoc(:attributed_to, single: true)))
    field(:in_reply_to, :comment, do: resolve(with_assoc(:in_reply_to, single: true)))
    field(:replies, list_of(:comment), do: resolve(with_assoc(:replies)))
  end

  input_object :comment_input do
    field(:content, non_null(:string))
  end

  def me(_, info) do
    with {:ok, actor} <- current_actor(info) do
      fields = requested_fields(info)
      {:ok, prepare(actor, fields)}
    end
  end

  def list_communities(_field_arguments, info) do
    fields = requested_fields(info)

    comms =
      MoodleNet.list_communities()
      |> prepare(fields)

    {:ok, comms}
  end

  def list_collections(%{community_local_id: community_local_id}, info) do
    fields = requested_fields(info)

    cols =
      MoodleNet.list_collections(community_local_id)
      |> prepare(fields)

    {:ok, cols}
  end

  def list_resources(%{collection_local_id: collection_local_id}, info) do
    fields = requested_fields(info)

    resources =
      MoodleNet.list_resources(collection_local_id)
      |> prepare(fields)

    {:ok, resources}
  end

  def list_comments(%{context_local_id: context_local_id}, info) do
    fields = requested_fields(info)

    comments =
      MoodleNet.list_comments(context_local_id)
      |> prepare(fields)

    {:ok, comments}
  end

  def list_replies(%{in_reply_to_local_id: in_reply_to_id}, info) do
    fields = requested_fields(info)

    comments =
      MoodleNet.list_replies(in_reply_to_id)
      |> prepare(fields)

    {:ok, comments}
  end

  def get_by_id_and_type(local_id, type) do
    Query.new()
    |> Query.where(local_id: local_id)
    |> Query.with_type(type)
    |> Query.one()
  end

  def resolve_by_id_and_type(type) do
    fn %{local_id: local_id}, info ->
      fields = requested_fields(info)

      case get_by_id_and_type(local_id, type) do
        nil -> {:ok, nil}
        comm -> {:ok, prepare(comm, fields)}
      end
    end
  end

  def create_user(%{user: attrs}, info) do
    attrs = attrs |> set_icon() |> set_location()

    with {:ok, %{actor: actor, user: user}} <- MoodleNet.Accounts.register_user(attrs),
         {:ok, token} <- MoodleNet.OAuth.create_token(user.id) do
      fields = requested_fields(info, :me)
      actor = prepare(actor, fields)
      auth_payload = %{token: token.hash, me: actor}
      {:ok, auth_payload}
    else
      {:error, _, %Ecto.Changeset{} = ch, _} ->
        error =
          %{fields: MoodleNetWeb.ChangesetView.translate_errors(ch)}
          |> Map.put(:message, "Validation errors")

        {:error, error}
    end
  end

  def create_session(%{email: email, password: password}, info) do
    with {:ok, user} <- MoodleNet.Accounts.authenticate_by_email_and_pass(email, password),
         {:ok, token} <- MoodleNet.OAuth.create_token(user.id) do
      actor = load_actor(user)
      fields = requested_fields(info, :me)
      actor = prepare(actor, fields)
      auth_payload = %{token: token.hash, me: actor}
      {:ok, auth_payload}
    else
      _ ->
        {:error, "Invalid credentials"}
    end
  end

  def create_community(_, %{community: attrs}, info) do
    attrs = set_icon(attrs)

    with {:ok, community} = MoodleNet.create_community(attrs) do
      fields = requested_fields(info)
      {:ok, prepare(community, fields)}
    end
  end

  def create_collection(_, %{collection: attrs, community_local_id: comm_id}, info) do
    if community = get_by_id_and_type(comm_id, "MoodleNet:Community") do
      attrs = set_icon(attrs)

      with {:ok, collection} = MoodleNet.create_collection(community, attrs) do
        fields = requested_fields(info)
        {:ok, prepare(collection, fields)}
      end
    else
      {:error, "community not found"}
    end
  end

  def create_resource(_, %{resource: attrs, collection_local_id: col_id}, info) do
    if collection = get_by_id_and_type(col_id, "MoodleNet:Collection") do
      attrs = set_icon(attrs)

      with {:ok, resource} = MoodleNet.create_resource(collection, attrs) do
        fields = requested_fields(info)
        {:ok, prepare(resource, fields)}
      end
    else
      {:error, "collection not found"}
    end
  end

  def create_reply(%{in_reply_to_local_id: in_reply_to_id} = args, info)
      when is_integer(in_reply_to_id) do
    with {:ok, author} <- current_actor(info),
         {:ok, in_reply_to} <- fetch_create_comment_in_reply_to(in_reply_to_id),
         {:ok, comment} <- MoodleNet.create_reply(author, in_reply_to, args.comment) do
      fields = requested_fields(info)
      {:ok, prepare(comment, fields)}
    end
  end

  def create_thread(%{context_local_id: context_id} = args, info) do
    with {:ok, author} <- current_actor(info),
         {:ok, context} <- fetch_create_comment_context(context_id),
         {:ok, comment} <- MoodleNet.create_thread(author, context, args.comment) do
      fields = requested_fields(info)
      {:ok, prepare(comment, fields)}
    end
  end

  defp fetch_create_comment_context(context_id) do
    Query.new()
    |> Query.where(local_id: context_id)
    |> Query.one()
    |> case do
      nil ->
        {:error, "context not found"}

      context
      when APG.has_type(context, "MoodleNet:Community") or
             APG.has_type(context, "MoodleNet:Collection") ->
        {:ok, context}

      _ ->
        {:error, "context not found"}
    end
  end

  defp fetch_create_comment_in_reply_to(local_id) do
    get_by_id_and_type(local_id, "Note")
    |> case do
      nil -> {:error, "in_reply_to comment not found"}
      comment -> {:ok, comment}
    end
  end

  defp set_icon(%{icon: url} = attrs) when is_binary(url) do
    Map.put(attrs, :icon, %{type: "Image", url: url})
  end

  defp set_icon(attrs), do: attrs

  defp set_location(%{location: location} = attrs) when is_binary(location) do
    Map.put(attrs, :location, %{type: "Place", content: location})
  end

  defp set_location(attrs), do: attrs

  defp current_user(%{context: %{current_user: nil}}), do: {:error, "You are not logged in"}
  defp current_user(%{context: %{current_user: user}}), do: {:ok, user}

  defp current_actor(info) do
    case current_user(info) do
      {:ok, user} ->
        {:ok, load_actor(user)}

      ret ->
        ret
    end
  end

  defp prepare([], _), do: []

  defp prepare([e | _] = list, fields) when APG.has_type(e, "MoodleNet:Community") do
    list
    |> preload_assoc_cond([:icon], fields)
    |> preload_aspect_cond([:actor_aspect], fields)
    |> Enum.map(&prepare(&1, fields))
  end

  defp prepare(e, fields) when APG.has_type(e, "MoodleNet:Community") do
    e
    |> preload_assoc_cond([:icon], fields)
    |> preload_aspect_cond([:actor_aspect], fields)
    |> prepare_common_fields()
  end

  defp prepare([e | _] = list, fields) when APG.has_type(e, "MoodleNet:Collection") do
    list
    |> preload_assoc_cond([:icon], fields)
    |> preload_aspect_cond([:actor_aspect], fields)
    |> Enum.map(&prepare(&1, fields))
  end

  defp prepare(e, fields) when APG.has_type(e, "MoodleNet:Collection") do
    e
    |> preload_assoc_cond([:icon], fields)
    |> preload_aspect_cond([:actor_aspect], fields)
    |> prepare_common_fields()
  end

  defp prepare([e | _] = list, fields) when APG.has_type(e, "MoodleNet:EducationalResource") do
    list
    |> preload_assoc_cond([:icon], fields)
    |> Enum.map(&prepare(&1, fields))
  end

  defp prepare(e, fields) when APG.has_type(e, "MoodleNet:EducationalResource") do
    e
    |> preload_assoc_cond([:icon], fields)
    |> prepare_common_fields()
  end

  defp prepare([e | _] = list, fields) when APG.has_type(e, "Note") do
    Enum.map(list, &prepare(&1, fields))
  end

  defp prepare(e, _fields) when APG.has_type(e, "Note") do
    prepare_common_fields(e)
  end

  defp prepare([e | _] = list, fields) when APG.has_type(e, "Person") do
    list
    |> preload_assoc_cond([:icon, :location], fields)
    |> preload_aspect_cond([:actor_aspect], fields)
    |> Enum.map(&prepare(&1, fields))
  end

  defp prepare(e, fields) when APG.has_type(e, "Person") do
    e
    |> preload_assoc_cond([:icon, :location], fields)
    |> preload_aspect_cond([:actor_aspect], fields)
    |> prepare_common_fields()
  end

  defp preload_assoc_cond(entities, assocs, fields) do
    assocs = Enum.filter(assocs, &(to_string(&1) in fields))

    entities
    |> Query.preload_assoc(assocs)
  end

  defp preload_aspect_cond(entities, aspects, _fields) do
    # TODO check fields to load aspects conditionally
    Query.preload_aspect(entities, aspects)
  end

  defp prepare_common_fields(entity) do
    entity
    |> Map.put(:local_id, Entity.local_id(entity))
    |> Map.put(:local, Entity.local?(entity))
    |> Map.update!(:name, &from_language_value/1)
    |> Map.update!(:content, &from_language_value/1)
    |> Map.update!(:summary, &from_language_value/1)
    |> Map.update!(:url, &List.first/1)
    |> Map.update(:preferred_username, nil, &from_language_value/1)
    |> Map.update(:icon, nil, &to_icon/1)
    |> Map.update(:location, nil, &to_location/1)
    |> Map.put(:followers_count, 10)
    |> Map.put(:following_count, 15)
    |> Map.put(:likes_count, 12)
    |> Map.put(:resources_count, 3)
    |> Map.put(:replies_count, 1)
    |> Map.put(:email, entity["email"])
    |> Map.put(:primary_language, entity["primary_language"])
    |> Map.put(:published, Entity.persistence(entity).inserted_at |> NaiveDateTime.to_iso8601())
    |> Map.put(:updated, Entity.persistence(entity).updated_at |> NaiveDateTime.to_iso8601())
  end

  defp from_language_value(string) when is_binary(string), do: string
  defp from_language_value(%{"und" => value}), do: value
  defp from_language_value(%{}), do: nil
  defp from_language_value(_), do: nil

  defp to_icon([entity | _]) when APG.is_entity(entity) do
    with [url | _] <- entity[:url] do
      url
    else
      _ -> nil
    end
  end

  defp to_icon(_), do: nil

  defp to_location([entity | _]) when APG.is_entity(entity) do
    with %{} = content <- entity[:content] do
      from_language_value(content)
    else
      _ -> nil
    end
  end

  defp to_location(_), do: nil

  defp requested_fields(info), do: Absinthe.Resolution.project(info) |> Enum.map(& &1.name)

  defp requested_fields(info, inner_key) do
    Absinthe.Resolution.project(info)
    |> Enum.find(&(&1.name == to_string(inner_key)))
    |> Map.fetch!(:selections)
    |> Enum.map(& &1.name)
  end

  defp with_assoc(assoc, opts \\ [single: false])

  defp with_assoc(assoc, opts) do
    fn parent, _, info ->
      fields = requested_fields(info)
      preload_assoc_args = {assoc, fields}

      batch(
        {__MODULE__, :preload_assoc, preload_assoc_args},
        parent,
        fn children_map ->
          children =
            children_map[Entity.local_id(parent)]
            |> ensure_single(opts[:single])

          {:ok, children}
        end
      )
    end
  end

  defp ensure_single(children, false), do: children

  defp ensure_single(children, true) do
    case children do
      [] -> nil
      [child] -> child
      # FIXME 
      [child | _] -> child
      # _ -> raise ArgumentError, "single assoc with more than an object: #{inspect(children)}"
    end
  end

  def preload_assoc({assoc, fields}, parent_list) do
    parent_list = Query.preload_assoc(parent_list, assoc)
    child_list = Enum.flat_map(parent_list, &Map.get(&1, assoc))

    child_map =
      prepare(child_list, fields)
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

  defp load_actor(user) do
    Query.new()
    |> Query.preload_aspect(:actor)
    |> Query.where(local_id: user.primary_actor_id)
    |> Query.one()
  end
end
