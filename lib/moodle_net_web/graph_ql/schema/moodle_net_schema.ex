defmodule MoodleNetWeb.GraphQL.MoodleNetSchema do
  use Absinthe.Schema.Notation

  alias ActivityPub.SQL.{Query}
  alias ActivityPub.Entity

  require ActivityPub.Guards, as: APG
  alias MoodleNetWeb.GraphQL.Errors

  object :auth_payload do
    field(:token, :string)
    field(:me, :me)
  end

  object :me do
    field(:id, :id)
    field(:local_id, :integer)
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
    field(:local_id, :integer)
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

  input_object :registration_input do
    field(:email, non_null(:string))
    field(:password, non_null(:string))
    field(:preferred_username, non_null(:string))
    field(:name, :string)
    field(:summary, :string)
    field(:location, :string)
    field(:icon, :string)
    field(:primary_language, :string)
  end

  input_object :update_profile_input do
    field(:preferred_username, :string)
    field(:name, :string)
    field(:summary, :string)
    field(:primary_language, :string)
    field(:location, :string)
    field(:icon, :string)
  end

  input_object :login_input do
    field(:email, non_null(:string))
    field(:password, non_null(:string))
  end

  object :community do
    field(:id, :string)
    field(:local_id, :integer)
    field(:local, :boolean)
    field(:type, list_of(:string))

    field(:name, :string)
    field(:content, :string)
    field(:summary, :string)

    field(:preferred_username, :string)

    field(:following_count, :integer)
    field(:followers_count, :integer)
    field(:likes_count, :integer)

    field(:icon, :string)

    field(:primary_language, :string)

    field(:collections_count, :integer)

    field(:collections, non_null(list_of(non_null(:collection))),
      do: resolve(with_assoc(:attributed_to_inv))
    )

    field(:comments, non_null(list_of(non_null(:comment))), do: resolve(with_assoc(:context_inv)))

    field(:followers, non_null(list_of(non_null(:user))),
      do: resolve(with_assoc(:followers, collection: true))
    )

    field(:likers, non_null(list_of(non_null(:user))), do: resolve(with_assoc(:likers)))

    field(:published, :string)
    field(:updated, :string)

    field(:followed, non_null(:boolean), do: resolve(with_bool_join(:follow)))
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
    field(:local_id, :integer)
    field(:local, :boolean)
    field(:type, list_of(:string))

    field(:name, :string)
    field(:content, :string)
    field(:summary, :string)

    field(:preferred_username, :string)

    field(:following_count, :integer)
    field(:followers_count, :integer)
    field(:likes_count, :integer)

    field(:icon, :string)

    field(:primary_language, :string)
    field(:resources_count, :integer)

    field(:followers, non_null(list_of(non_null(:user))),
      do: resolve(with_assoc(:followers, collection: true))
    )

    field(:resources, non_null(list_of(non_null(:resource))),
      do: resolve(with_assoc(:attributed_to_inv))
    )

    field(:comments, non_null(list_of(non_null(:comment))), do: resolve(with_assoc(:context_inv)))

    field(:communities, non_null(list_of(non_null(:community))),
      do: resolve(with_assoc(:attributed_to))
    )

    field(:likers, non_null(list_of(non_null(:user))), do: resolve(with_assoc(:likers)))

    field(:published, :string)
    field(:updated, :string)

    field(:followed, non_null(:boolean), do: resolve(with_bool_join(:follow)))
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
    field(:local_id, :integer)
    field(:local, :boolean)
    field(:type, list_of(:string))

    field(:name, :string)
    field(:content, :string)
    field(:summary, :string)

    field(:icon, :string)

    field(:likes_count, :integer)
    field(:primary_language, :string)
    field(:url, :string)

    field(:collections, non_null(list_of(non_null(:collection))),
      do: resolve(with_assoc(:attributed_to))
    )

    field(:likers, non_null(list_of(non_null(:user))), do: resolve(with_assoc(:likers)))

    field(:published, :string)
    field(:updated, :string)

    field(:same_as, :string)
    field(:in_language, list_of(non_null(:string)))
    field(:public_access, :boolean)
    field(:is_accesible_for_free, :boolean)
    field(:license, :string)
    field(:learning_resource_type, :string)
    field(:educational_use, list_of(non_null(:string)))
    field(:time_required, :integer)
    field(:typical_age_range, :string)
  end

  input_object :resource_input do
    field(:id, :string)
    field(:local_id, :integer)
    field(:local, :boolean)
    field(:type, list_of(:string))
    field(:name, :string)
    field(:content, :string)
    field(:summary, :string)
    field(:icon, :string)
    field(:primary_language, :string)
    field(:url, :string)
    field(:same_as, :string)
    field(:in_language, list_of(non_null(:string)))
    field(:public_access, :boolean)
    field(:is_accesible_for_free, :boolean)
    field(:license, :string)
    field(:learning_resource_type, :string)
    field(:educational_use, list_of(non_null(:string)))
    field(:time_required, :integer)
    field(:typical_age_range, :string)
  end

  object :comment do
    field(:id, :string)
    field(:local_id, :integer)
    field(:local, :boolean)
    field(:type, list_of(:string))

    field(:content, :string)
    field(:likes_count, :integer)
    field(:replies_count, :integer)
    field(:published, :string)
    field(:updated, :string)

    field(:likers, non_null(list_of(non_null(:user))), do: resolve(with_assoc(:likers)))

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

  def list_threads(%{context_local_id: context_local_id}, info) do
    fields = requested_fields(info)

    comments =
      MoodleNet.list_threads(context_local_id)
      |> prepare(fields)

    {:ok, comments}
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
    end
    |> Errors.handle_error()
  end

  def update_profile(%{profile: attrs}, info) do
    with {:ok, current_actor} <- current_actor(info),
         {:ok, current_actor} <- MoodleNet.Accounts.update_user(current_actor, attrs) do
      fields = requested_fields(info)
      current_actor = prepare(current_actor, fields)
      {:ok, current_actor}
    end
    |> Errors.handle_error()
  end

  def delete_user(_, info) do
    with {:ok, current_actor} <- current_actor(info) do
      MoodleNet.Accounts.delete_user(current_actor)
      {:ok, true}
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
        Errors.invalid_credential_error()
    end
  end

  def delete_session(_, info) do
    with {:ok, _} <- current_user(info) do
      MoodleNet.OAuth.revoke_token(info.context.auth_token)
      {:ok, true}
    end
  end

  def reset_password_request(%{email: email}, _info) do
    # Note: This can be done async, but then, the async tests will fail
    MoodleNet.Accounts.reset_password_request(email)
    {:ok, true}
  end

  def reset_password(%{token: token, password: password}, _info) do
    with {:ok, _} <- MoodleNet.Accounts.reset_password(token, password) do
      {:ok, true}
    end
    |> Errors.handle_error()
  end

  def confirm_email(%{token: token}, _info) do
    with {:ok, _} <- MoodleNet.Accounts.confirm_email(token) do
      {:ok, true}
    end
    |> Errors.handle_error()
  end

  def create_community(%{community: attrs}, info) do
    attrs = set_icon(attrs)

    with {:ok, actor} <- current_actor(info),
         {:ok, community} <- MoodleNet.create_community(actor, attrs) do
      fields = requested_fields(info)
      {:ok, prepare(community, fields)}
    end
    |> Errors.handle_error()
  end

  def update_community(%{community: changes, community_local_id: id}, info) do
    with {:ok, community} <- fetch(id, "MoodleNet:Community"),
         {:ok, community} <- MoodleNet.update_community(community, changes) do
      fields = requested_fields(info)
      {:ok, prepare(community, fields)}
    end
    |> Errors.handle_error()
  end

  def delete_community(%{local_id: id}, info) do
    with {:ok, author} <- current_actor(info),
         {:ok, community} <- fetch(id, "MoodleNet:Community"),
         :ok <- MoodleNet.delete_community(author, community) do
      {:ok, true}
    end
    |> Errors.handle_error()
  end

  def join_community(%{community_local_id: id}, info) do
    with {:ok, actor} <- current_actor(info),
         {:ok, community} <- fetch(id, "MoodleNet:Community") do
      MoodleNet.join_community(actor, community)
    end
    |> Errors.handle_error()
  end

  def undo_join_community(%{community_local_id: id}, info) do
    with {:ok, actor} <- current_actor(info),
         {:ok, community} <- fetch(id, "MoodleNet:Community") do
      MoodleNet.undo_follow(actor, community)
    end
    |> Errors.handle_error()
  end

  def follow_collection(%{collection_local_id: id}, info) do
    with {:ok, actor} <- current_actor(info),
         {:ok, collection} <- fetch(id, "MoodleNet:Collection") do
      MoodleNet.follow_collection(actor, collection)
    end
    |> Errors.handle_error()
  end

  def undo_follow_collection(%{collection_local_id: id}, info) do
    with {:ok, actor} <- current_actor(info),
         {:ok, collection} <- fetch(id, "MoodleNet:Collection") do
      MoodleNet.undo_follow(actor, collection)
    end
    |> Errors.handle_error()
  end

  def destroy_like(%{local_id: id}, info) do
    with {:ok, liker} <- current_actor(info) do
      MoodleNet.undo_like(liker, id)
    end
    |> Errors.handle_error()
  end

  def like_comment(%{local_id: comment_id}, info) do
    with {:ok, liker} <- current_actor(info),
         {:ok, comment} <- fetch(comment_id, "Note") do
      MoodleNet.like_comment(liker, comment)
    end
    |> Errors.handle_error()
  end

  def like_resource(%{local_id: resource_id}, info) do
    with {:ok, liker} <- current_actor(info),
         {:ok, resource} <- fetch(resource_id, "MoodleNet:EducationalResource") do
      MoodleNet.like_resource(liker, resource)
    end
    |> Errors.handle_error()
  end

  def undo_like_comment(%{local_id: comment_id}, info) do
    with {:ok, actor} <- current_actor(info),
         {:ok, comment} <- fetch(comment_id, "Note") do
      MoodleNet.undo_like(actor, comment)
    end
    |> Errors.handle_error()
  end

  def undo_like_resource(%{local_id: resource_id}, info) do
    with {:ok, actor} <- current_actor(info),
         {:ok, resource} <- fetch(resource_id, "MoodleNet:EducationalResource") do
      MoodleNet.undo_like(actor, resource)
    end
    |> Errors.handle_error()
  end

  def create_collection(%{collection: attrs, community_local_id: comm_id}, info) do
    with {:ok, actor} <- current_actor(info),
         {:ok, community} <- fetch(comm_id, "MoodleNet:Community"),
         attrs = set_icon(attrs),
         {:ok, collection} <- MoodleNet.create_collection(actor, community, attrs) do
      fields = requested_fields(info)
      {:ok, prepare(collection, fields)}
    end
    |> Errors.handle_error()
  end

  def update_collection(%{collection: changes, collection_local_id: id}, info) do
    with {:ok, collection} <- fetch(id, "MoodleNet:Collection"),
         {:ok, collection} <- MoodleNet.update_collection(collection, changes) do
      fields = requested_fields(info)
      {:ok, prepare(collection, fields)}
    end
    |> Errors.handle_error()
  end

  def delete_collection(%{local_id: id}, info) do
    with {:ok, author} <- current_actor(info),
         {:ok, collection} <- fetch(id, "MoodleNet:Collection"),
         :ok <- MoodleNet.delete_collection(author, collection) do
      {:ok, true}
    end
    |> Errors.handle_error()
  end

  def create_resource(%{resource: attrs, collection_local_id: col_id}, info) do
    with {:ok, actor} <- current_actor(info),
         {:ok, collection} <- fetch(col_id, "MoodleNet:Collection"),
         attrs = set_icon(attrs),
         {:ok, resource} = MoodleNet.create_resource(actor, collection, attrs) do
      fields = requested_fields(info)
      {:ok, prepare(resource, fields)}
    end
    |> Errors.handle_error()
  end

  def update_resource(%{resource: changes, resource_local_id: id}, info) do
    with {:ok, resource} <- fetch(id, "MoodleNet:EducationalResource"),
         {:ok, resource} <- MoodleNet.update_resource(resource, changes) do
      fields = requested_fields(info)
      {:ok, prepare(resource, fields)}
    end
    |> Errors.handle_error()
  end

  def delete_resource(%{local_id: id}, info) do
    with {:ok, author} <- current_actor(info),
         {:ok, resource} <- fetch(id, "MoodleNet:EducationalResource"),
         :ok <- MoodleNet.delete_resource(author, resource) do
      {:ok, true}
    end
    |> Errors.handle_error()
  end

  def copy_resource(attrs, info) do
    %{resource_local_id: res_id, collection_local_id: col_id} = attrs

    with {:ok, author} <- current_actor(info),
         {:ok, resource} <- fetch(res_id, "MoodleNet:EducationalResource"),
         {:ok, collection} <- fetch(col_id, "MoodleNet:Collection"),
         {:ok, resource_copy} <- MoodleNet.copy_resource(author, resource, collection) do
      fields = requested_fields(info)
      {:ok, prepare(resource_copy, fields)}
    end
    |> Errors.handle_error()
  end

  def create_reply(%{in_reply_to_local_id: in_reply_to_id} = args, info)
      when is_integer(in_reply_to_id) do
    with {:ok, author} <- current_actor(info),
         {:ok, in_reply_to} <- fetch(in_reply_to_id, "Note"),
         {:ok, comment} <- MoodleNet.create_reply(author, in_reply_to, args.comment) do
      fields = requested_fields(info)
      {:ok, prepare(comment, fields)}
    end
    |> Errors.handle_error()
  end

  def create_thread(%{context_local_id: context_id} = args, info) do
    with {:ok, author} <- current_actor(info),
         {:ok, context} <- fetch_create_comment_context(context_id),
         {:ok, comment} <- MoodleNet.create_thread(author, context, args.comment) do
      fields = requested_fields(info)
      {:ok, prepare(comment, fields)}
    end
    |> Errors.handle_error()
  end

  def delete_comment(%{local_id: id}, info) do
    with {:ok, author} <- current_actor(info),
         {:ok, comment} <- fetch(id, "Note"),
         :ok <- MoodleNet.delete_comment(author, comment) do
      {:ok, true}
    end
    |> Errors.handle_error()
  end

  defp get_by_id_and_type(local_id, type) do
    Query.new()
    |> Query.where(local_id: local_id)
    |> Query.with_type(type)
    |> Query.one()
  end

  defp fetch(local_id, type) do
    case get_by_id_and_type(local_id, type) do
      nil -> Errors.not_found_error(local_id, type)
      entity -> {:ok, entity}
    end
  end

  defp fetch_create_comment_context(context_id) do
    Query.new()
    |> Query.where(local_id: context_id)
    |> Query.one()
    |> case do
      nil ->
        Errors.not_found_error(context_id, "Context")

      context
      when APG.has_type(context, "MoodleNet:Community") or
             APG.has_type(context, "MoodleNet:Collection") ->
        {:ok, context}

      _ ->
        Errors.not_found_error(context_id, "Context")
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

  defp current_user(%{context: %{current_user: nil}}), do: Errors.unauthorized_error()
  defp current_user(%{context: %{current_user: user}}), do: {:ok, user}

  defp current_actor(info) do
    case current_user(info) do
      {:ok, user} ->
        {:ok, user.actor}

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
    |> preload_aspect_cond([:resource_aspect], fields)
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

    assocs = add_assoc_for_counters(assocs, fields, followers: "followersCount")

    Query.preload_assoc(entities, assocs)
  end

  defp add_assoc_for_counters(assocs, fields, keyword) do
    Enum.reduce(keyword, assocs, fn {collection, field}, assocs ->
      add_assoc_for_counter(assocs, fields, field, collection)
    end)
  end

  defp add_assoc_for_counter(assocs, fields, field, collection) do
    if field in fields,
      do: [{collection, {[:collection], []}} | assocs],
      else: assocs
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

  defp count_items(entity, collection) do
    case entity[collection] do
      %ActivityPub.SQL.AssociationNotLoaded{} -> nil
      collection -> collection[:total_items]
    end
  end

  defp requested_fields(info), do: Absinthe.Resolution.project(info) |> Enum.map(& &1.name)

  defp requested_fields(info, inner_key) do
    Absinthe.Resolution.project(info)
    |> Enum.find(&(&1.name == to_string(inner_key)))
    |> case do
      nil ->
        []

      inner ->
        inner
        |> Map.get(:selections)
        |> Enum.map(& &1.name)
    end
  end

  defp with_assoc(assoc, opts \\ [])

  defp with_assoc(assoc, opts) do
    fn parent, _, info ->
      fields = requested_fields(info)
      preload_args = {assoc, fields}

      args =
        if Keyword.get(opts, :collection, false),
          do: {__MODULE__, :preload_collection, preload_args},
          else: {__MODULE__, :preload_assoc, preload_args}

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

  defp with_bool_join(:follow) do
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
  def preload_assoc({assoc, fields}, parent_list) do
    parent_list = Query.preload_assoc(parent_list, assoc)

    child_list =
      parent_list
      |> Enum.flat_map(&Map.get(&1, assoc))
      |> Enum.uniq_by(&Entity.local_id(&1))

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

  defp load_actor(user) do
    Query.new()
    |> Query.preload_aspect(:actor)
    |> Query.where(local_id: user.actor_id)
    |> Query.one()
  end
end
