defmodule ActivityPub.SQL.Query do
  alias ActivityPub.{SQLEntity, Entity}
  import SQLEntity, only: [to_entity: 1]
  import Ecto.Query, only: [from: 2]
  require ActivityPub.Guards, as: APG
  alias MoodleNet.Repo

  def new() do
    from(entity in SQLEntity, as: :entity)
  end

  def all(query) do
    query
    # |> print_query()
    |> Repo.all()
    |> Enum.map(&to_entity/1)
  end

  def one(query) do
    query
    |> Repo.one()
    |> to_entity()
  end

  def with_type(query, type) when is_binary(type) do
    from([entity: entity] in query,
      where: fragment("? @> array[?]", entity.type, ^type)
    )
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

  def has(%Ecto.Query{} = query, assoc_name, entity) when APG.is_entity(entity),
    do: has(query, assoc_name, Entity.local_id(entity))

  def belongs_to(%Ecto.Query{} = query, assoc_name, entity) when APG.is_entity(entity),
    do: belongs_to(query, assoc_name, Entity.local_id(entity))

  for sql_aspect <- ActivityPub.SQLAspect.all() do
    for {assoc_name, table_name, _assoc} <- sql_aspect.__sql_aspect__(:associations) do
      def has(%Ecto.Query{} = query, unquote(assoc_name), ext_id) when is_integer(ext_id) do
        from([entity: entity] in query,
          join: rel in fragment(unquote(table_name)),
          on: entity.local_id == rel.subject_id and rel.target_id == ^ext_id
        )
      end

      def belongs_to(%Ecto.Query{} = query, unquote(assoc_name), ext_id)
          when is_integer(ext_id) do
        from([entity: entity] in query,
          join: rel in fragment(unquote(table_name)),
          on: entity.local_id == rel.target_id and rel.subject_id == ^ext_id
        )
      end
    end
  end

  alias ActivityPub.SQL.Paginate

  def paginate(query, opts \\ %{}) do
    Paginate.call(query, opts)
  end

  # defp print_query(query) do
  #   {query_str, args} = Ecto.Adapters.SQL.to_sql(:all, Repo, query)
  #   IO.puts("#{query_str} <=> #{inspect(args)}")
  #   query
  # end
end
