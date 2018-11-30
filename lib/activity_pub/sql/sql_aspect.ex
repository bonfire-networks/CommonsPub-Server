defmodule ActivityPub.SQLAspect do
  alias ActivityPub.SQLObjectAspect
  alias ActivityPub.Entity

  def all(), do: [SQLObjectAspect]

  defmacro __using__(options) do
    quote bind_quoted: [options: options] do
      aspect = Keyword.fetch!(options, :aspect)
      def aspect(), do: unquote(aspect)

      persistence_method = Keyword.fetch!(options, :persistence_method)
      def persistence_method(), do: unquote(persistence_method)

      @table_name Keyword.get(options, :table_name)
      require ActivityPub.SQLAspect

      ActivityPub.SQLAspect.create_schema(persistence_method, aspect, __MODULE__)
      ActivityPub.SQLAspect.def_create_changeset(persistence_method, aspect, __MODULE__)
    end
  end

  defmacro inject_in_sql_entity_schema(sql_aspect) do
    quote bind_quoted: [sql_aspect: sql_aspect] do
      aspect = sql_aspect.aspect()

      case sql_aspect.persistence_method() do
        :table ->
          has_one(aspect.name(), sql_aspect, foreign_key: :local_id)

        :fields ->
          ActivityPub.SQLAspect.inject_fields(aspect)
      end
    end
  end

  defmacro create_schema(persistence_method, aspect, sql_aspect) do
    quote bind_quoted: [persistence_method: persistence_method, aspect: aspect, sql_aspect: sql_aspect] do
      case persistence_method do
        :table ->
          use Ecto.Schema

          @primary_key {:local_id, :id, autogenerate: true}
          schema @table_name do
            ActivityPub.SQLAspect.inject_fields(aspect)
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

  defmacro def_create_changeset(persistence_method, aspect, sql_aspect) do
    quote bind_quoted: [persistence_method: persistence_method, aspect: aspect, sql_aspect: sql_aspect] do
      require ActivityPub.Guards, as: APG

      def create_changeset(changeset, entity) when not APG.has_aspect(entity, unquote(aspect)),
        do: changeset

      case persistence_method do
        :table ->
          def create_changeset(changeset, entity) when APG.has_aspect(entity, unquote(aspect)) do
            changes = Entity.fields_for(entity, unquote(aspect))
            assoc_ch = Ecto.Changeset.change(struct(unquote(sql_aspect)), changes)
            Ecto.Changeset.put_assoc(changeset, unquote(aspect).name(), assoc_ch)
          end

        :fields ->
          def create_changeset(changeset, entity) when APG.has_aspect(entity, unquote(aspect)) do
            changes = Entity.fields_for(entity, unquote(aspect))
            Ecto.Changeset.change(changeset, changes)
          end
      end
    end
  end
end
