defmodule ActivityPub.SQL.Query do
  alias ActivityPub.{SQLEntity, Entity}
  import SQLEntity, only: [to_entity: 1]
  import Ecto.Query, only: [from: 2]
  require ActivityPub.Guards, as: APG
  alias MoodleNet.Repo
  alias ActivityPub.SQL.Paginate

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

  def paginate(%Ecto.Query{} = query, opts \\ %{}) do
    Paginate.call(query, opts)
  end

  def with_type(%Ecto.Query{} = query, type) when is_binary(type) do
    from([entity: entity] in query,
      where: fragment("? @> array[?]", entity.type, ^type)
    )
  end

  def select(%Ecto.Query{} = query) do
    from [entity, ..., rel] in query,
      select: {"select", rel.target_id, entity}
  end

  for sql_aspect <- ActivityPub.SQLAspect.all() do
    short_name = sql_aspect.aspect().short_name()
    field_name = sql_aspect.field_name()

    case sql_aspect.persistence_method() do
      m when m in [:fields, :embedded] ->
        def preload_aspect(query, unquote(short_name)), do: query

      :table ->
        # already loaded
        def preload_aspect(
              %Ecto.Query{aliases: %{unquote(field_name) => _}} = query,
              unquote(short_name)
            ),
            do: query

        def preload_aspect(query, unquote(short_name)) do
          from([entity: entity] in query,
            left_join: aspect in assoc(entity, unquote(field_name)),
            as: unquote(field_name),
            preload: [{unquote(field_name), aspect}]
          )
        end
    end
  end

  def preload_aspect(query, aspects) when is_list(aspects),
    do: Enum.reduce(aspects, query, &preload_aspect(&2, &1))

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

  def belongs_to(%Ecto.Query{} = query, assoc_name, entity) when APG.is_entity(entity),
    do: belongs_to(query, assoc_name, Entity.local_id(entity))

  for sql_aspect <- ActivityPub.SQLAspect.all() do
    for {assoc_name, table_name, _assoc} <- sql_aspect.__sql_aspect__(:associations) do
      def has(%Ecto.Query{} = query, unquote(assoc_name), ext_id) when is_integer(ext_id) do
        from([entity: entity] in query,
          join: rel in fragment(unquote(table_name)),
          as: unquote(assoc_name),
          on: entity.local_id == rel.subject_id and rel.target_id == ^ext_id
        )
      end

      def has(%Ecto.Query{} = query, unquote(assoc_name), entities) when is_list(entities) do
        ext_ids = to_local_ids(entities)
        from([entity: entity] in query,
          join: rel in fragment(unquote(table_name)),
          as: unquote(assoc_name),
          on: entity.local_id == rel.subject_id and rel.target_id in ^ext_ids
        )
      end

      def belongs_to(%Ecto.Query{} = query, unquote(assoc_name), ext_id)
          when is_integer(ext_id) do
        from([entity: entity] in query,
          join: rel in fragment(unquote(table_name)),
          as: unquote(assoc_name),
          on: entity.local_id == rel.target_id and rel.subject_id == ^ext_id
        )
      end

      def belongs_to(%Ecto.Query{} = query, unquote(assoc_name), entities)
          when is_list(entities) do
        ext_ids = to_local_ids(entities)
        from([entity: entity] in query,
          join: rel in fragment(unquote(table_name)),
          as: unquote(assoc_name),
          on: entity.local_id == rel.target_id and rel.subject_id in ^ext_ids
        )
      end
    end
  end

  for sql_aspect <- ActivityPub.SQLAspect.all() do
    case sql_aspect.persistence_method() do
      :table ->
        field_name = sql_aspect.field_name()

        for {assoc_name, _, _} <- sql_aspect.__sql_aspect__(:associations) do
          defp normalize_assoc(unquote(assoc_name)),
            do: {unquote(field_name), unquote(assoc_name)}
        end

      m when m in [:fields, :embedded] ->
        for {assoc_name, _, _} <- sql_aspect.__sql_aspect__(:associations) do
          defp normalize_assoc(unquote(assoc_name)), do: unquote(assoc_name)
        end
    end
  end

  def preload_assoc(entity, preload) when not is_list(preload),
    do: preload_assoc(entity, List.wrap(preload))

  def preload_assoc(e, _preloads) when APG.is_entity(e) and not APG.has_status(e, :loaded),
    do: preload_assoc_error(e)

  def preload_assoc(entity, preloads) when APG.has_status(entity, :loaded) do
    sql_entity = Entity.persistence(entity)
    preloads = Enum.map(preloads, &normalize_assoc/1)

    Repo.preload(sql_entity, preloads)
    |> to_entity()
  end

  def preload_assoc(entities, preloads) when is_list(entities) do
    sql_entities =
      Enum.map(entities, fn entity ->
        case Entity.persistence(entity) do
          nil -> preload_assoc_error(entity)
          persistence -> persistence
        end
      end)

    preloads = Enum.map(preloads, &normalize_assoc/1)

    Repo.preload(sql_entities, preloads)
    |> to_entity()
  end

  defp preload_assoc_error(e),
    do:
      raise(
        ArgumentError,
        "invalid status: #{Entity.status(e)}. Only entities with status :loaded can preload assocs"
      )

  # defp print_query(query) do
  #   {query_str, args} = Ecto.Adapters.SQL.to_sql(:all, Repo, query)
  #   IO.puts("#{query_str} <=> #{inspect(args)}")
  #   query
  # end
end
