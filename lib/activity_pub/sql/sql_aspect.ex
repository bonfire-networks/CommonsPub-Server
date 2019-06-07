# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.SQLAspect do
  @moduledoc """
  `SQLAspect` receives a runtime `ActivityPub.Aspect` module, and creates a `SQLAspect`, with an Ecto schema with the same fields. It also contains the functionality to store its fields in the database, which can be done in 4 different ways:

  1.   In its own table with all the aspect fields. They are connected using the `local_id` column which is `primary_key` and `foreign_key` at the same time. So all the tables share the same `local_id` column making it easy to load the full entity.
  2.   The aspect fields are stored in the main table `activity_pub_objects`.
  3.   The aspect fields are stored in a JSONB column in the main table `activity_pub_objects`. Not 100% implemented.
  4.   The aspect fields are stored in the `extension_fields` column. This is 0% implemented but it is possible.

  So, in a similar way to `ActivityPub.Aspect`s only dealing with their fields, `ActivityPub.SQLAspect`s only store their fields, in a predefined way.

  We have an `SQLAspect` for each `ActivityPub.Aspect`:
  *   `ActivityPub.SQLActivityAspect`
  *   `ActivityPub.SQLActorAspect`
  *   `ActivityPub.SQLCollectionAspect`
  *   `ActivityPub.SQLObjectAspect`

  The definitions of those modules are very small, because the functionality is defined here in `ActivityPub.SQLAspect`.

  """

  alias ActivityPub.{
    SQLObjectAspect,
    SQLActorAspect,
    SQLActivityAspect,
    SQLCollectionAspect
  }

  alias ActivityPub.SQL.Associations.{ManyToMany, BelongsTo, Collection}

  def all(),
    do: [
      SQLObjectAspect,
      SQLActorAspect,
      SQLActivityAspect,
      SQLCollectionAspect,
      MoodleNet.AP.SQLCommunityAspect,
      MoodleNet.AP.SQLCollectionAspect,
      MoodleNet.AP.SQLResourceAspect
    ]

  @doc """
  FIXME: make this similar to aspect where the user can redefine assocs and fields to be persisted in a way other than the default!
  This way we can remove :inv property
  """
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

        opts =
          field_def
          |> Map.take([:virtual, :default])
          |> Keyword.new()

        field(name, type, opts)
      end
    end
  end

  @doc """
  `SQLAspects` define their own associations.

  When it is a functional relation, it defines a `belongs_to` association, for example, `ActivityPub.ActorAspect` defines `followers_id`, which is always a single `collection`: [migrations/20181105145654_create_activity_pub_tables.exs#L46](https://gitlab.com/moodlenet/servers/federated/blob/develop/priv/repo/migrations/20181105145654_create_activity_pub_tables.exs#L46)

  However, when a relation is not functional, a `many_to_many` relation is created, which means a “join table” is necessary, for example, an `ActivityPub.ActivityAspect` can have many `Actors`: [migrations/20181105145654_create_activity_pub_tables.exs#L46](https://gitlab.com/moodlenet/servers/federated/blob/develop/priv/repo/migrations/20181105145654_create_activity_pub_tables.exs#L46)

  *It is important to note that naming is playing an important role in the library. The library can infer the name of the tables and columns using the name of the `aspects` and fields.*
  """
  defmacro inject_assocs(associations) do
    quote bind_quoted: [associations: associations] do
      Enum.map(associations, fn
        %ManyToMany{} = assoc ->
          [subject_key, target_key] = assoc.join_keys

          many_to_many(assoc.name, ActivityPub.SQLEntity,
            join_through: assoc.table_name,
            join_keys: [{subject_key, :local_id}, {target_key, :local_id}]
          )

        %Collection{repeated: true} ->
          nil

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
      repeated: assoc.repeated,
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
