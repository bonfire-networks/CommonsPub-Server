defmodule ActivityPub.SQLAspect do
  alias ActivityPub.{SQLObjectAspect, SQLActorAspect, SQLActivityAspect}

  def all(), do: [SQLObjectAspect, SQLActorAspect, SQLActivityAspect]

  defmacro __using__(options) do
    quote bind_quoted: [options: options] do
      aspect = Keyword.fetch!(options, :aspect)
      def aspect(), do: unquote(aspect)

      persistence_method = Keyword.fetch!(options, :persistence_method)
      def persistence_method(), do: unquote(persistence_method)

      @table_name Keyword.get(options, :table_name)
      require ActivityPub.SQLAspect

      ActivityPub.SQLAspect.create_schema(persistence_method, aspect, __MODULE__)
    end
  end

  defmacro inject_in_sql_entity_schema(sql_aspect) do
    quote bind_quoted: [sql_aspect: sql_aspect] do
      aspect = sql_aspect.aspect()

      case sql_aspect.persistence_method() do
        :table ->
          has_one(aspect.name(), sql_aspect, foreign_key: :local_id)

        :embedded ->
          embeds_one(aspect.name(), sql_aspect)
          ActivityPub.SQLAspect.inject_assocs(aspect)

        :fields ->
          ActivityPub.SQLAspect.inject_fields(aspect)
          ActivityPub.SQLAspect.inject_assocs(aspect)
      end
    end
  end

  defmacro create_schema(persistence_method, aspect, sql_aspect) do
    quote bind_quoted: [
            persistence_method: persistence_method,
            aspect: aspect,
            sql_aspect: sql_aspect
          ] do
      case persistence_method do
        :table ->
          use Ecto.Schema

          @primary_key {:local_id, :id, autogenerate: true}
          schema @table_name do
            ActivityPub.SQLAspect.inject_fields(aspect)
            ActivityPub.SQLAspect.inject_assocs(aspect)
          end

        :embedded_schema ->
          use Ecto.Schema

          @primary_key false
          embedded_schema do
            ActivityPub.SQLAspect.inject_fields(aspect)
          end

        :fields ->
          []
      end
    end
  end

  defmacro inject_fields(aspect) do
    quote bind_quoted: [aspect: aspect] do
      for name <- aspect.__aspect__(:fields) do
        type = aspect.__aspect__(:type, name)

        field(name, type)
      end
    end
  end

  defmacro inject_assocs(aspect) do
    quote bind_quoted: [aspect: aspect] do
      for assoc_name <- aspect.__aspect__(:associations) do
        # FIXME use options!!
        short_name = aspect.short_name()
        table_name = "activity_pub_#{short_name}_#{assoc_name}s"

        aspect.__aspect__(:association, assoc_name)
        |> case do
          %{cardinality: :one} ->
            # FIXME
            many_to_many(assoc_name, ActivityPub.SQLEntity,
              join_through: table_name,
              join_keys: [subject_id: :local_id, target_id: :local_id]
            )

          # has_one(assoc_name, table_name, foreign_key: :local_id)
          %{cardinality: :many} ->
            many_to_many(assoc_name, ActivityPub.SQLEntity,
              join_through: table_name,
              join_keys: [subject_id: :local_id, target_id: :local_id]
            )
        end
      end
    end
  end
end
