defmodule ActivityPub.SQLAspect do
  alias ActivityPub.{SQLObjectAspect, SQLActorAspect, SQLActivityAspect}

  def all(), do: [SQLObjectAspect, SQLActorAspect, SQLActivityAspect]

  defmacro __using__(options) do
    quote bind_quoted: [options: options] do
      aspect = Keyword.fetch!(options, :aspect)
      def aspect(), do: unquote(aspect)

      persistence_method = Keyword.fetch!(options, :persistence_method)
      def persistence_method(), do: unquote(persistence_method)

      require ActivityPub.SQLAspect

      case persistence_method do
        :table ->
          @table_name Keyword.get(options, :table_name)
          @field_name Keyword.get(options, :field_name, aspect.name())

        :embedded ->
          if Keyword.has_key?(options, :table_name),
            do: raise(ArgumentError, "embedded SQLAspect does not need option :table_name")

          @table_name nil
          @field_name Keyword.get(options, :field_name, aspect.name())

        :fields ->
          if Keyword.has_key?(options, :table_name),
            do: raise(ArgumentError, "fields SQLAspect does not need option :table_name")

          if Keyword.has_key?(options, :field_name),
            do: raise(ArgumentError, "fields SQLAspect does not need option :field_name")

          @table_name nil
          @field_name nil
      end

      def table_name(), do: @table_name
      def field_name(), do: @field_name

      @associations ActivityPub.SQLAspect.build_associations(aspect, options)
      def __sql_aspect__(:associations), do: @associations
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
          ActivityPub.SQLAspect.inject_assocs(sql_aspect.__sql_aspect__(:associations))

        :fields ->
          ActivityPub.SQLAspect.inject_fields(aspect)
          ActivityPub.SQLAspect.inject_assocs(sql_aspect.__sql_aspect__(:associations))
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
            ActivityPub.SQLAspect.inject_assocs(@associations)
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

  defmacro inject_assocs(associations) do
    quote bind_quoted: [associations: associations] do
      for {assoc_name, table_name, assoc} <- associations do
        join_keys =
          if assoc.inv do
            [target_id: :local_id, subject_id: :local_id]
          else
            [subject_id: :local_id, target_id: :local_id]
          end

        many_to_many(assoc_name, ActivityPub.SQLEntity,
          join_through: table_name,
          join_keys: join_keys
        )
      end
    end
  end

  def build_associations(aspect, opts) do
    assoc_prefix = Keyword.get(opts, :assoc_prefix, "activity_pub_#{aspect.short_name()}_")

    for assoc_name <- aspect.__aspect__(:associations) do
      assoc = aspect.__aspect__(:association, assoc_name)
      if inv_name = assoc.inv do
        table_name = "#{assoc_prefix}#{inv_name}s"
        {assoc_name, to_string(table_name), assoc}
      else
        table_name = "#{assoc_prefix}#{assoc_name}s"
        {assoc_name, table_name, assoc}
      end
    end
  end
end
