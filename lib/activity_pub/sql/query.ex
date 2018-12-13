defmodule ActivityPub.SQL.Query do
  alias ActivityPub.{SQLEntity, Entity}
  import SQLEntity, only: [to_entity: 1]
  import Ecto.Query, only: [from: 2]
  require ActivityPub.Guards, as: APG
  alias MoodleNet.Repo
  alias ActivityPub.SQL.Paginate

  alias ActivityPub.SQLAssociations.{ManyToMany, BelongsTo}

  def new() do
    from(entity in SQLEntity, as: :entity)
  end

  def all(%Ecto.Query{} = query) do
    query
    # |> print_query()
    |> Repo.all()
    |> to_entity()
  end

  def one(%Ecto.Query{} = query) do
    query
    |> Repo.one()
    |> to_entity()
  end

  def reload(entity) when APG.is_entity(entity) and APG.has_status(entity, :loaded) do
    Entity.aspects(entity)

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
        def preload_aspect(%Ecto.Query{} = query, unquote(short_name)), do: query

      :table ->
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

  def preload_aspect(%Ecto.Query{} = query, aspects) when is_list(aspects),
    do: Enum.reduce(aspects, query, &preload_aspect(&2, &1))

  def preload_aspect(entity, preload) when not is_list(preload),
    do: preload_aspect(entity, List.wrap(preload))

  def preload_aspect(e, _preloads) when APG.is_entity(e) and not APG.has_status(e, :loaded),
    do: preload_error(e)

  def preload_aspect(entity, preloads) when APG.has_status(entity, :loaded) do
    sql_entity = Entity.persistence(entity)

    Repo.preload(sql_entity, preloads)
    |> to_entity()
  end

  def preload_aspect([e | _] = entities, preloads) when APG.is_entity(e) do
    sql_entities = loaded_sql_entities!(entities)

    # FIXME check preloads are valid!
    Repo.preload(sql_entities, preloads)
    |> to_entity()
  end

  defp to_local_ids(entities) do
    Enum.map(entities, fn
      e when APG.is_entity(e) -> Entity.local_id(e)
      int when is_integer(int) -> int
    end)
  end

  def belongs_to(%Ecto.Query{} = query, assoc_name, entity) when APG.is_entity(entity),
    do: belongs_to(query, assoc_name, Entity.local_id(entity))

  def has(%Ecto.Query{} = query, assoc_name, entity) when APG.is_entity(entity),
    do: has(query, assoc_name, Entity.local_id(entity))

  for sql_aspect <- ActivityPub.SQLAspect.all() do
    Enum.map(sql_aspect.__sql_aspect__(:associations), fn
      %ManyToMany{inv: false} = assoc ->
        def has(%Ecto.Query{} = query, unquote(assoc.name), ext_id) when is_integer(ext_id) do
          from([entity: entity] in query,
            join: rel in fragment(unquote(assoc.table_name)),
            as: unquote(assoc.name),
            on: entity.local_id == rel.subject_id and rel.target_id == ^ext_id
          )
        end

        def has(%Ecto.Query{} = query, unquote(assoc.name), entities) when is_list(entities) do
          ext_ids = to_local_ids(entities)

          from([entity: entity] in query,
            join: rel in fragment(unquote(assoc.table_name)),
            as: unquote(assoc.name),
            on: entity.local_id == rel.subject_id and rel.target_id in ^ext_ids
          )
        end

        def belongs_to(%Ecto.Query{} = query, unquote(assoc.name), ext_id)
            when is_integer(ext_id) do
          from([entity: entity] in query,
            join: rel in fragment(unquote(assoc.table_name)),
            as: unquote(assoc.name),
            on: entity.local_id == rel.target_id and rel.subject_id == ^ext_id
          )
        end

        def belongs_to(%Ecto.Query{} = query, unquote(assoc.name), entities)
            when is_list(entities) do
          ext_ids = to_local_ids(entities)

          from([entity: entity] in query,
            join: rel in fragment(unquote(assoc.table_name)),
            as: unquote(assoc.name),
            on: entity.local_id == rel.target_id and rel.subject_id in ^ext_ids
          )
        end

      %ManyToMany{} = assoc ->
        def has(%Ecto.Query{} = query, unquote(assoc.name), ext_id) when is_integer(ext_id) do
          from([entity: entity] in query,
            join: rel in fragment(unquote(assoc.table_name)),
            as: unquote(assoc.name),
            on: entity.local_id == rel.target_id and rel.subject_id == ^ext_id
          )
        end

        def has(%Ecto.Query{} = query, unquote(assoc.name), entities) when is_list(entities) do
          ext_ids = to_local_ids(entities)

          from([entity: entity] in query,
            join: rel in fragment(unquote(assoc.table_name)),
            as: unquote(assoc.name),
            on: entity.local_id == rel.target_id and rel.subject_id in ^ext_ids
          )
        end

        def belongs_to(%Ecto.Query{} = query, unquote(assoc.name), ext_id)
            when is_integer(ext_id) do
          from([entity: entity] in query,
            join: rel in fragment(unquote(assoc.table_name)),
            as: unquote(assoc.name),
            on: entity.local_id == rel.subject_id and rel.target_id == ^ext_id
          )
        end

        def belongs_to(%Ecto.Query{} = query, unquote(assoc.name), entities)
            when is_list(entities) do
          ext_ids = to_local_ids(entities)

          from([entity: entity] in query,
            join: rel in fragment(unquote(assoc.table_name)),
            as: unquote(assoc.name),
            on: entity.local_id == rel.subject_id and rel.target_id in ^ext_ids
          )
        end

      %BelongsTo{} ->
        []
    end)
  end

  defp normalize_preloads(preload) when is_atom(preload), do: normalize_preloads([preload])

  defp normalize_preloads(preloads) when is_list(preloads) do
    Enum.map(preloads, &normalize_preload/1)
  end

  defp normalize_preload({preload, preload_assoc}) when is_atom(preload_assoc),
    do: normalize_preload({preload, [preload_assoc]})

  defp normalize_preload({preload, preload_assocs}) when is_list(preload_assocs) do
    normalized_preloads = normalize_preloads(preload_assocs)

    case normalize_preload(preload) do
      {aspect, assoc} ->
        {aspect, [{assoc, normalized_preloads}]}

      assoc ->
        {assoc, normalized_preloads}
    end
  end

  # FIXME normalize assoc should be private
  for sql_aspect <- ActivityPub.SQLAspect.all() do
    case sql_aspect.persistence_method() do
      :table ->
        field_name = sql_aspect.field_name()

        for assoc <- sql_aspect.__sql_aspect__(:associations) do
          defp normalize_preload(unquote(assoc.name)),
            do: {unquote(field_name), unquote(assoc.name)}
        end

      m when m in [:fields, :embedded] ->
        for assoc <- sql_aspect.__sql_aspect__(:associations) do
          defp normalize_preload(unquote(assoc.name)), do: unquote(assoc.name)
        end
    end
  end

  def preload_assoc(entity, preload) when not is_list(preload),
    do: preload_assoc(entity, List.wrap(preload))

  def preload_assoc(e, _preloads) when APG.is_entity(e) and not APG.has_status(e, :loaded),
    do: preload_error(e)

  def preload_assoc(entity, preloads) when APG.has_status(entity, :loaded) do
    sql_entity = Entity.persistence(entity)
    preloads = normalize_preloads(preloads)

    Repo.preload(sql_entity, preloads)
    |> to_entity()
  end

  def preload_assoc([e | _] = entities, preloads) when APG.is_entity(e) do
    sql_entities = loaded_sql_entities!(entities)

    preloads = Enum.map(preloads, &normalize_preload/1)

    Repo.preload(sql_entities, preloads)
    |> to_entity()
  end

  def preload_assoc([e | _] = entities, preloads) when APG.is_entity(e) do
    sql_entities = loaded_sql_entities!(entities)

    preloads = normalize_preloads(preloads)

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
        "invalid status: #{Entity.status(e)}. Only entities with status :loaded can be preloaded"
      )

  # defp print_query(query) do
  #   {query_str, args} = Ecto.Adapters.SQL.to_sql(:all, Repo, query)
  #   IO.puts("#{query_str} <=> #{inspect(args)}")
  #   query
  # end
end
