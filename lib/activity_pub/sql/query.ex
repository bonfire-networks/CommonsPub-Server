defmodule ActivityPub.SQL.Query do
  alias ActivityPub.{SQLEntity, Entity, UrlBuilder}
  import SQLEntity, only: [to_entity: 1]
  import Ecto.Query, only: [from: 2]
  require ActivityPub.Guards, as: APG
  alias MoodleNet.Repo
  alias ActivityPub.SQL.{Common, Paginate}
  alias ActivityPub.SQL.Associations.{ManyToMany, BelongsTo, Collection}

  def new() do
    from(entity in SQLEntity, as: :entity)
  end

  def all(%Ecto.Query{} = query) do
    query
    # |> print_query()
    |> Repo.all()
    |> to_entity()
  end

  # FIXME this should not be here?
  def delete_all(%Ecto.Query{} = query) do
    query
    |> Repo.delete_all()
  end

  def one(%Ecto.Query{} = query) do
    query
    |> Repo.one()
    |> to_entity()
  end

  # FIXME add test to those two functions
  def first(%Ecto.Query{} = query, order_by \\ :local_id) do
    query
    |> Ecto.Query.first(order_by)
    |> one()
  end

  def last(%Ecto.Query{} = query, order_by \\ :local_id) do
    query
    |> Ecto.Query.last(order_by)
    |> one()
  end

  def get_by_local_id(id, opts \\ []) when is_integer(id) do
    new()
    |> where(local_id: id)
    |> preload_aspect(Keyword.get(opts, :aspect, []))
    |> one()
  end

  def get_by_id(id, opts \\ []) when is_binary(id) do
    case UrlBuilder.get_local_id(id) do
      {:ok, local_id} ->
        get_by_local_id(local_id, opts)

      :error ->
        new()
        |> where(id: id)
        |> preload_aspect(Keyword.get(opts, :aspect, []))
        |> one()
    end
  end

  def reload(entity) when APG.is_entity(entity) and APG.has_status(entity, :loaded) do
    new()
    |> where(local_id: Entity.local_id(entity))
    |> preload_aspect(Entity.aspects(entity))
    |> one()
  end

  def paginate(%Ecto.Query{} = query, opts \\ %{}) do
    Paginate.call(query, opts)
  end

  def with_type(%Ecto.Query{} = query, type) when is_binary(type) do
    from([entity: entity] in query,
      where: fragment("? @> array[?]", entity.type, ^type)
    )
  end

  def where(%Ecto.Query{} = query, clauses) do
    from(e in query,
      where: ^clauses
    )
  end

  for sql_aspect <- ActivityPub.SQLAspect.all() do
    short_name = sql_aspect.aspect().short_name()
    field_name = sql_aspect.field_name()

    def preload_aspect(%Ecto.Query{} = query, unquote(sql_aspect.aspect())),
      do: preload_aspect(query, unquote(short_name))

    case sql_aspect.persistence_method() do
      m when m in [:fields, :embedded] ->
        defp normalize_aspect(unquote(short_name)), do: nil
        defp normalize_aspect(unquote(field_name)), do: nil
        defp normalize_aspect(unquote(sql_aspect)), do: nil
        defp normalize_aspect(unquote(sql_aspect.aspect())), do: nil
        def preload_aspect(%Ecto.Query{} = query, unquote(short_name)), do: query

      :table ->
        defp normalize_aspect(unquote(short_name)), do: unquote(field_name)
        defp normalize_aspect(unquote(field_name)), do: unquote(field_name)
        defp normalize_aspect(unquote(sql_aspect)), do: unquote(field_name)
        defp normalize_aspect(unquote(sql_aspect.aspect())), do: unquote(field_name)

        # already loaded
        def preload_aspect(
              %Ecto.Query{aliases: %{unquote(field_name) => _}} = query,
              unquote(short_name)
            ),
            do: query

        def preload_aspect(%Ecto.Query{} = query, unquote(short_name)) do
          from([entity: entity] in query,
            left_join: aspect in assoc(entity, unquote(field_name)),
            as: unquote(field_name),
            preload: [{unquote(field_name), aspect}]
          )
        end
    end
  end

  defp normalize_aspect(aspect),
    do: raise(ArgumentError, "Invalid aspect #{inspect(aspect)}")

  def preload_aspect(%Ecto.Query{} = query, aspects) when is_list(aspects),
    do: Enum.reduce(aspects, query, &preload_aspect(&2, &1))

  def preload_aspect(e, _preloads) when APG.is_entity(e) and not APG.has_status(e, :loaded),
    do: preload_error(e)

  def preload_aspect(entity, :all) when APG.is_entity(entity) do
    preload_aspect(entity, Entity.aspects(entity))
  end

  def preload_aspect(entity, preloads) when APG.has_status(entity, :loaded) do
    [entity] = preload_aspect([entity], preloads)
    entity
  end

  def preload_aspect([e | _] = entities, preloads) when APG.is_entity(e) do
    sql_entities = loaded_sql_entities!(entities)
    preloads = normalize_aspects(preloads)

    Repo.preload(sql_entities, preloads)
    |> to_entity()
  end

  defp normalize_aspects(aspect) when not is_list(aspect),
    do: normalize_aspects(List.wrap(aspect))

  defp normalize_aspects(aspects) when is_list(aspects) do
    Enum.reduce(aspects, [], fn aspect, acc ->
      case normalize_aspect(aspect) do
        nil -> acc
        ret -> [ret | acc]
      end
    end)
  end

  defp to_local_ids(entities) do
    Enum.map(entities, fn
      e when APG.is_entity(e) -> Entity.local_id(e)
      int when is_integer(int) -> int
    end)
  end

  def belongs_to(%Ecto.Query{} = query, assoc_name, local_id) when is_integer(local_id),
    do: belongs_to(query, assoc_name, [local_id])

  def belongs_to(%Ecto.Query{} = query, assoc_name, entity) when APG.is_entity(entity),
    do: belongs_to(query, assoc_name, [Entity.local_id(entity)])

  def belongs_to(%Ecto.Query{} = query, assoc_name, [entity | _] = list)
      when APG.is_entity(entity),
      do: belongs_to(query, assoc_name, to_local_ids(list))

  def has(%Ecto.Query{} = query, assoc_name, local_id) when is_integer(local_id),
    do: has(query, assoc_name, [local_id])

  def has(%Ecto.Query{} = query, assoc_name, entity) when APG.is_entity(entity),
    do: has(query, assoc_name, [Entity.local_id(entity)])

  def has(%Ecto.Query{} = query, assoc_name, [entity | _] = list) when APG.is_entity(entity),
    do: has(query, assoc_name, to_local_ids(list))

  def has?(subject, rel, target)
      when APG.is_entity(subject) and APG.has_status(subject, :loaded) and APG.is_entity(target) and
             APG.has_status(target, :loaded)
      when APG.is_entity(subject) and APG.has_status(subject, :loaded) and is_integer(target),
      do: do_has?(subject, rel, target)

  for sql_aspect <- ActivityPub.SQLAspect.all() do
    Enum.map(sql_aspect.__sql_aspect__(:associations), fn
      %ManyToMany{
        name: name,
        aspect: aspect,
        table_name: table_name,
        join_keys: [subject_key, target_key]
      } ->
        def has(%Ecto.Query{} = query, unquote(name), ext_ids) when is_list(ext_ids) do
          from([entity: entity] in query,
            join: rel in fragment(unquote(table_name)),
            as: unquote(name),
            on:
              entity.local_id == field(rel, unquote(subject_key)) and
                field(rel, unquote(target_key)) in ^ext_ids
          )
        end

        defp do_has?(subject, unquote(name), target)
             when APG.has_aspect(subject, unquote(aspect)) do
          target_id = Common.local_id(target)

          subject_id = Common.local_id(subject)

          from(rel in unquote(table_name),
            where:
              ^subject_id == field(rel, unquote(subject_key)) and
                ^target_id == field(rel, unquote(target_key))
          )
          |> Repo.exists?()
        end

        def belongs_to(%Ecto.Query{} = query, unquote(name), ext_ids)
            when is_list(ext_ids) do
          from([entity: entity] in query,
            join: rel in fragment(unquote(table_name)),
            as: unquote(name),
            on:
              entity.local_id == field(rel, unquote(target_key)) and
                field(rel, unquote(subject_key)) in ^ext_ids
          )
        end

      %Collection{
        name: name,
        aspect: aspect,
        table_name: table_name,
        join_keys: [subject_key, target_key]
      } ->
        defp do_has?(subject, unquote(name), target)
             when APG.has_aspect(subject, unquote(aspect)) do
          subject_id = Common.local_id(subject[unquote(name)])
          target_id = Common.local_id(target)

          from(rel in unquote(table_name),
            where:
              ^subject_id == field(rel, unquote(subject_key)) and
                ^target_id == field(rel, unquote(target_key))
          )
          |> Repo.exists?()
        end

      # TODO has and belongs_to

      # TODO all belongs_to assoc

      %BelongsTo{} ->
        []
    end)
  end

  defp normalize_preload_assocs(assoc) when is_atom(assoc), do: normalize_preload_assocs([assoc])

  defp normalize_preload_assocs(assocs) when is_list(assocs) do
    Enum.map(assocs, &normalize_preload_assoc/1)
  end

  defp normalize_preload_assoc({assoc, preload_assoc}) when is_atom(preload_assoc),
    do: normalize_preload_assoc({assoc, [preload_assoc]})

  defp normalize_preload_assoc({assoc, preload_assocs}) when is_list(preload_assocs) do
    normalize_preload_assoc({assoc, {[], preload_assocs}})
  end

  defp normalize_preload_assoc({assoc, {preload_aspects, preload_assocs}})
       when is_list(preload_aspects) and is_list(preload_assocs) do
    normalized_aspects = normalize_aspects(preload_aspects)
    normalized_preloads = normalize_preload_assocs(preload_assocs)

    preloads = normalized_aspects ++ normalized_preloads

    # FIXME assoc can be repetead in normalized_aspects, take a look
    # maybe it is a problem maybe not
    case normalize_preload_assoc(assoc) do
      {aspect, assoc} ->
        {aspect, [{assoc, preloads}]}

      assoc ->
        {assoc, preloads}
    end
  end

  # FIXME normalize assoc should be private
  for sql_aspect <- ActivityPub.SQLAspect.all() do
    case sql_aspect.persistence_method() do
      :table ->
        field_name = sql_aspect.field_name()

        for assoc <- sql_aspect.__sql_aspect__(:associations) do
          defp normalize_preload_assoc(unquote(assoc.name)),
            do: {unquote(field_name), unquote(assoc.name)}
        end

      m when m in [:fields, :embedded] ->
        for assoc <- sql_aspect.__sql_aspect__(:associations) do
          defp normalize_preload_assoc(unquote(assoc.name)), do: unquote(assoc.name)
        end
    end
  end

  def preload_assoc(entity, preload) when not is_list(preload),
    do: preload_assoc(entity, List.wrap(preload))

  def preload_assoc(e, _preloads) when APG.is_entity(e) and not APG.has_status(e, :loaded),
    do: preload_error(e)

  def preload_assoc(entity, preloads) when APG.has_status(entity, :loaded) do
    sql_entity = Entity.persistence(entity)
    preloads = normalize_preload_assocs(preloads)

    Repo.preload(sql_entity, preloads)
    |> to_entity()
  end

  def preload_assoc([e | _] = entities, preloads) when APG.is_entity(e) do
    sql_entities = loaded_sql_entities!(entities)

    preloads = normalize_preload_assocs(preloads)

    Repo.preload(sql_entities, preloads)
    |> to_entity()
  end

  defp loaded_sql_entities!(entities) do
    Enum.map(entities, fn entity ->
      case Entity.persistence(entity) do
        nil -> preload_error(entity)
        persistence -> persistence
      end
    end)
  end

  defp preload_error(e),
    do:
      raise(
        ArgumentError,
        "Invalid status: #{Entity.status(e)}. Only entities with status :loaded can be preloaded"
      )

  # defp print_query(query) do
  #   {query_str, args} = Ecto.Adapters.SQL.to_sql(:all, Repo, query)
  #   IO.puts("#{query_str} <=> #{inspect(args)}")
  #   query
  # end
end
