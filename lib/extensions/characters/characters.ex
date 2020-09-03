# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Character.Characters do
  alias MoodleNet.{Actors, Common, Feeds, Follows, Repo}
  alias MoodleNet.GraphQL.{Fields, Page}
  alias MoodleNet.Common.Contexts
  # alias CommonsPub.Character
  alias CommonsPub.Character.Queries
  alias MoodleNet.Feeds.FeedActivities
  # alias MoodleNet.Users.User
  alias MoodleNet.Workers.APPublishWorker
  alias Pointers.Pointer
  alias Pointers

  def cursor(:followers), do: &[&1.follower_count, &1.id]
  def test_cursor(:followers), do: &[&1["followerCount"], &1["id"]]

  @doc """
  Retrieves a single character by arbitrary filters.
  Used by:
  * GraphQL Item queries
  * ActivityPub integration
  * Various parts of the codebase that need to query for characters (inc. tests)
  """
  def one(filters), do: Repo.single(Queries.query(CommonsPub.Character, filters))

  @doc """
  Retrieves a list of characters by arbitrary filters.
  Used by:
  * Various parts of the codebase that need to query for characters (inc. tests)
  """
  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(CommonsPub.Character, filters))}

  def fields(group_fn, filters \\ [])
      when is_function(group_fn, 1) do
    {:ok, fields} = many(filters)
    {:ok, Fields.new(fields, group_fn)}
  end

  @doc """
  Retrieves an Page of characters according to various filters

  Used by:
  * GraphQL resolver single-parent resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])

  def page(cursor_fn, %{} = page_opts, base_filters, data_filters, count_filters) do
    base_q = Queries.query(CommonsPub.Character, base_filters)
    data_q = Queries.filter(base_q, data_filters)
    count_q = Queries.filter(base_q, count_filters)

    with {:ok, [data, counts]} <- Repo.transact_many(all: data_q, count: count_q) do
      {:ok, Page.new(data, counts, cursor_fn, page_opts)}
    end
  end

  @doc """
  Retrieves an Pages of characters according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def pages(
        cursor_fn,
        group_fn,
        page_opts,
        base_filters \\ [],
        data_filters \\ [],
        count_filters \\ []
      )

  def pages(cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters) do
    Contexts.pages(
      Queries,
      CommonsPub.Character,
      cursor_fn,
      group_fn,
      page_opts,
      base_filters,
      data_filters,
      count_filters
    )
  end

  ## mutations

  def create(creator, %{character: attrs, id: id, profile: %{name: name}})
      when is_map(attrs) do
    create(creator, Map.put(Map.put(attrs, :id, id), :name, name))
  end

  def create(creator, %{character: attrs, profile: %{name: name}}) when is_map(attrs) do
    create(creator, Map.put(attrs, :name, name))
  end

  def create(creator, %{character: attrs, id: id}) when is_map(attrs) do
    create(creator, Map.put(attrs, :id, id))
  end

  def create(creator, %{profile: %{name: name}} = attrs) when is_map(attrs) do
    create(creator, Map.put(Map.delete(attrs, :profile), :name, name))
  end

  def create(creator, attrs) when is_map(attrs) do
    # IO.inspect(character_create: attrs)
    attrs = Actors.prepare_username(attrs)

    # IO.inspect(attrs)

    Repo.transact_with(fn ->
      with {:ok, actor} <- Actors.create(attrs),
           {:ok, character_attrs} <- create_boxes(actor, attrs),
           {:ok, character} <- insert_character(creator, actor, character_attrs),
           #  act_attrs = %{verb: "created", is_local: true},
           #  {:ok, activity} <- Activities.create(creator, character, act_attrs),
           #  :ok <- publish(creator, character, activity, :created),

           {:ok, _follow} <- Follows.create(creator, character, %{is_local: true}) do
        {:ok, character}
      end
    end)
  end

  defp create_boxes(%{peer_id: nil}, attrs), do: create_local_boxes(attrs)
  defp create_boxes(%{peer_id: _}, attrs), do: create_remote_boxes(attrs)

  defp create_local_boxes(attrs) do
    with {:ok, inbox} <- Feeds.create(),
         {:ok, outbox} <- Feeds.create() do
      extra = %{inbox_id: inbox.id, outbox_id: outbox.id}
      {:ok, Map.merge(attrs, extra)}
    end
  end

  defp create_remote_boxes(attrs) do
    with {:ok, outbox} <- Feeds.create() do
      {:ok, Map.put(attrs, :outbox_id, outbox.id)}
    end
  end

  defp insert_character(creator, actor, attrs) do
    cs = CommonsPub.Character.create_changeset(creator, actor, attrs)
    IO.inspect(cs)
    with {:ok, character} <- Repo.insert(cs), do: {:ok, %{character | actor: actor}}
  end

  # defp insert_character_with_characteristic(creator, characteristic, actor, attrs) do
  #   cs = CommonsPub.Character.create_changeset(creator, characteristic, actor, nil, attrs)
  #   with {:ok, character} <- Repo.insert(cs), do: {:ok, %{ character | actor: actor, characteristic: characteristic }}
  # end

  # defp insert_character_with_context(creator, context, actor, attrs) do
  #   cs = CommonsPub.Character.create_changeset(creator, actor, context, attrs)
  #   with {:ok, character} <- Repo.insert(cs), do: {:ok, %{ character | actor: actor, context: context }}
  # end

  # defp insert_character(creator, characteristic, context, actor, attrs) do
  #   cs = CommonsPub.Character.create_changeset(creator, characteristic, actor, context, attrs)
  #   with {:ok, character} <- Repo.insert(cs), do: {:ok, %{ character | actor: actor, context: context, characteristic: characteristic }}
  # end

  @doc "Takes a Pointer to something and creates a character based on it"
  def characterise(user, %Pointer{} = pointer) do
    thing = MoodleNet.Meta.Pointers.follow!(pointer)

    if(is_nil(thing.character_id)) do
      characterise(user, thing)
    else
      {:ok, %{thing.character | characteristic: thing}}
    end
  end

  @doc "Takes anything and creates a character based on it"
  def characterise(user, %{} = thing) do
    # IO.inspect(thing)
    thing_name = thing.__struct__
    thing_context_module = apply(thing_name, :context_module, [])

    char_attrs = characterisation(thing_name, thing, thing_context_module)

    # IO.inspect(char_attrs)
    # characterise(user, pointer, %{})

    Repo.transact_with(fn ->
      # :ok <- {:ok, IO.inspect(character)}, # wtf, without this line character is not set in the next one
      #  {:ok, thing} <- character_link(thing, character, thing_context_module)
      with {:ok, character} <- create(user, char_attrs) do
        {:ok, character}
      end
    end)
  end

  @doc "Transform the fields of any Thing into those of a character. It is recommended to define a `charactersation/1` function (transforming the data similarly to `characterisation_default/2`) in your Thing's context module which will also be executed if present."
  def characterisation(thing_name, thing, thing_context_module) do
    attrs = characterisation_default(thing_name, thing)

    # IO.inspect(attrs)

    if(Kernel.function_exported?(thing_context_module, :characterisation, 1)) do
      # IO.inspect(function_exists_in: thing_context_module)
      apply(thing_context_module, :characterisation, [attrs])
    else
      attrs
    end
  end

  @doc "Transform the generic fields of anything to be turned into a character."
  def characterisation_default(thing_name, thing) do
    thing
    # use Thing name as character facet/trope
    |> Map.put(:facet, thing_name |> to_string() |> String.split(".") |> List.last())
    # include the linked thing
    |> Map.put(:characteristic, thing)
    # avoid reusing IDs
    |> Map.delete(:id)
    # convert to map
    |> Map.from_struct()
    |> Map.delete(:__meta__)
  end

  defp publish(creator, character, activity, :created) do
    feeds = [
      creator.outbox_id,
      character.outbox_id,
      Feeds.instance_outbox_id()
    ]

    with :ok <- FeedActivities.publish(activity, feeds),
         {:ok, _} <- ap_publish("create", character.id, creator.id, character.actor.peer_id),
         do: :ok
  end

  # defp publish(creator, character, context, activity, :created) do
  #   feeds = [
  #     context.outbox_id, creator.outbox_id,
  #     character.outbox_id, Feeds.instance_outbox_id(),
  #   ]
  #   with :ok <- FeedActivities.publish(activity, feeds),
  #        {:ok, _} <- ap_publish("create", character.id, creator.id, character.actor.peer_id),
  #     do: :ok
  # end

  defp publish(character, :updated) do
    # TODO: wrong if edited by admin
    with {:ok, _} <-
           ap_publish("update", character.id, character.creator_id, character.actor.peer_id),
         do: :ok
  end

  defp publish(character, :deleted) do
    # TODO: wrong if edited by admin
    with {:ok, _} <-
           ap_publish("delete", character.id, character.creator_id, character.actor.peer_id),
         do: :ok
  end

  defp ap_publish(verb, context_id, user_id, nil) do
    APPublishWorker.enqueue(verb, %{
      "context_id" => context_id,
      "user_id" => user_id
    })
  end

  defp ap_publish(_, _, _, _), do: :ok

  def update(user, %CommonsPub.Character{} = character, %{character: attrs}) when is_map(attrs) do
    update(user, character, attrs)
  end

  def update(user, %CommonsPub.Character{} = character, attrs) do
    character = Repo.preload(character, :actor)

    Repo.transact_with(fn ->
      # TODO: take the user who is performing the update
      with {:ok, character} <-
             Repo.update(CommonsPub.Character.update_changeset(character, attrs)),
           {:ok, actor} <- Actors.update(user, character.actor, attrs),
           :ok <- publish(character, :updated) do
        {:ok, %{character | actor: actor}}
      end
    end)
  end

  def soft_delete(%CommonsPub.Character{} = character) do
    Repo.transact_with(fn ->
      with {:ok, character} <- Common.soft_delete(character),
           :ok <- publish(character, :deleted) do
        {:ok, character}
      end
    end)
  end

  # TODO move these to a common module

  @doc "conditionally update a map"
  def maybe_put(map, _key, nil), do: map
  def maybe_put(map, key, value), do: Map.put(map, key, value)
end
