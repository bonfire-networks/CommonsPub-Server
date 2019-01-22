defmodule ActivityPub.SQLAspect do
  alias ActivityPub.{SQLObjectAspect, SQLActorAspect, SQLActivityAspect, SQLCollectionAspect, SQLResourceAspect}

  alias ActivityPub.SQL.Associations.{ManyToMany, BelongsTo, Collection}

  def all(), do: [SQLObjectAspect, SQLActorAspect, SQLActivityAspect, SQLCollectionAspect, SQLResourceAspect]

  # FIXME make this similar to aspect where the user can redifine
  # assocs and fields to be persisted in another way than the default!
  # This way we can remove :inv property
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
            do: raise(ArgumentError, "Embedded SQLAspect does not need option :table_name")

          @table_name nil
          @field_name Keyword.get(options, :field_name, aspect.name())

        :fields ->
          if Keyword.has_key?(options, :table_name),
            do: raise(ArgumentError, "Fields SQLAspect do not need option :table_name")

          if Keyword.has_key?(options, :field_name),
            do: raise(ArgumentError, "Fields SQLAspect do not need option :field_name")

          @table_name nil
          @field_name nil
      end

      def table_name(), do: @table_name
      def field_name(), do: @field_name

      @associations ActivityPub.SQLAspect.build_associations(__MODULE__, aspect, options)
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
        field_def = aspect.__aspect__(:field, name)

        type = if field_def.functional, do: field_def.type, else: {:array, field_def.type}

        field(name, type)
      end
    end
  end

  defmacro inject_assocs(associations) do
    quote bind_quoted: [associations: associations] do
      Enum.map(associations, fn
        %ManyToMany{} = assoc ->
          [subject_key, target_key] = assoc.join_keys

          many_to_many(assoc.name, ActivityPub.SQLEntity,
            join_through: assoc.table_name,
            join_keys: [{subject_key, :local_id}, {target_key, :local_id}]
          )

        %Collection{} = assoc ->
          belongs_to(assoc.name, ActivityPub.SQLEntity, references: :local_id)

        %BelongsTo{} = assoc ->
          belongs_to(assoc.name, ActivityPub.SQLEntity, references: :local_id)
      end)
    end
  end

  def build_associations(sql_aspect, aspect, opts) do
    for assoc_name <- aspect.__aspect__(:associations) do
      assoc = aspect.__aspect__(:association, assoc_name)
      build_assoc(assoc, sql_aspect, aspect, opts)
    end
  end

  defp build_assoc(%{functional: false} = assoc, sql_aspect, aspect, opts) do
    assoc_prefix = Keyword.get(opts, :assoc_prefix, "activity_pub_#{aspect.short_name()}_")

    table_name =
      if inv_name = assoc.inv,
        do: "#{assoc_prefix}#{inv_name}s",
        else: "#{assoc_prefix}#{assoc.name}s"

    table_name = String.replace(table_name, ~r/ss$/, "s")

    join_keys = if assoc.inv, do: [:target_id, :subject_id], else: [:subject_id, :target_id]

    %ManyToMany{
      aspect: aspect,
      sql_aspect: sql_aspect,
      name: assoc.name,
      type: assoc.type,
      autogenerated: assoc.autogenerated,
      table_name: table_name,
      join_keys: join_keys
    }
  end

  defp build_assoc(%{functional: true, type: "Collection"} = assoc, sql_aspect, aspect, _opts) do
    foreign_key = "#{assoc.name}_id"

    %Collection{
      aspect: aspect,
      sql_aspect: sql_aspect,
      name: assoc.name,
      type: assoc.type,
      autogenerated: assoc.autogenerated,
      foreign_key: foreign_key
    }
  end

  defp build_assoc(%{functional: true} = assoc, sql_aspect, aspect, _opts) do
    foreign_key = "#{assoc.name}_id"

    %BelongsTo{
      aspect: aspect,
      sql_aspect: sql_aspect,
      name: assoc.name,
      type: assoc.type,
      autogenerated: assoc.autogenerated,
      foreign_key: foreign_key
    }
  end
end
