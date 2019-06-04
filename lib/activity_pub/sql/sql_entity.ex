# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.SQLEntity do
  @moduledoc """
  Most of the SQL work is in this `SQLEntity`. It defines the database fields that every `ActivityPub.Entity` must implement: `id`, `@context`, `type` and two helper fields: `local` and `extension_fields` (a JSONB column to store all _ActivityStreams extension_ fields).

  (_TODO: Maybe we are not using the 'local' field anymore?_)

  The Ecto schemas are quite different from a regular project, as we wanted everything to be easily extensible. The database revolves around a primary table called `activity_pub_objects`. You can consult the [initial schema](https://www.dbdesigner.net/designer/schema/208495), which has changed slightly over time, or better yet, make a dump of the current database.

  `SQLEntity` has a `primary_key` of `local_id` and a `has_one` relation with each defined `ActivityPub.SQLAspect` (using `local_id` as the `foreign_key`). This means that every `ActivityPub.SQLAspect` has the same `local_id` as its `ActivityPub.SQLEntity` parent.
  """
  use Ecto.Schema
  require ActivityPub.Guards, as: APG

  alias ActivityPub.Entity
  alias ActivityPub.{SQLAspect, Context, UrlBuilder, Metadata}
  alias ActivityPub.SQL.{AssociationNotLoaded, FieldNotLoaded, Query}
  alias MoodleNet.Repo

  @primary_key {:local_id, :id, autogenerate: true}
  schema "activity_pub_objects" do
    field(:id, :string)
    field(:"@context", Context)
    field(:type, {:array, :string})
    field(:local, :boolean, default: false)
    field(:extension_fields, :map, default: %{})

    timestamps()

    require ActivityPub.SQLAspect

    for sql_aspect <- SQLAspect.all() do
      ActivityPub.SQLAspect.inject_in_sql_entity_schema(sql_aspect)
    end
  end

  @doc """
  ## Persists and entity in the database

  So when a new Entity has to be stored the process is something like:

  1. `SQLEntity` creates a changeset with the common fields: id, type, @context, and extension_fields

  2. Each implemented `ActivityPub.SQLAspect` receives the changeset and depending on its way to store the fields, in the `insert_changeset_for_aspect` function:

      a. It creates a new changeset which is connected to the main changeset.

      b. It adds more changes to the changeset

  3. For each association in each `ActivityPub.Aspect`, a new changeset is generated—calling the same function, as `insert_changeset` is a recursive function — and then it is correctly connected to the main changeset, using the `put_assocs_in_changeset` function.

      a. If the association is already an _entity_, it just creates the association.

      b. If the association is also new entity, it is stored as well.

  4. When all the fields and associations are done, it inserts the main changeset. If any error occurred, it returns the error and nothing is stored.

  5. Once the changeset has been inserted, the inverse process starts, using `to_entity/1`.

  `insert` only accepts an `ActivityPub.Entity` whose state is :new
  """
  def insert(entity, repo \\ Repo) when APG.is_entity(entity) and APG.has_status(entity, :new) do
    changeset = insert_changeset(entity)
    with {:ok, sql_entity} <- repo.insert(changeset) do
      {:ok, to_entity(sql_entity)}
    end
  end

  defp insert_changeset(entity) when APG.has_status(entity, :new) do
    ch =
      %__MODULE__{}
      |> Ecto.Changeset.change(from_entity_fields(entity))

    Entity.aspects(entity)
    |> Enum.reduce(ch, fn aspect, ch ->
      insert_changeset_for_aspect(ch, entity, aspect)
    end)
  end

  defp insert_changeset(entity) when APG.has_status(entity, :loaded),
    do: Entity.persistence(entity)

  defp insert_changeset(entity) when APG.is_entity(entity) do
    Ecto.Changeset.change(%__MODULE__{})
    |> Ecto.Changeset.add_error(
      :status,
      "invalid status: #{Entity.status(entity)}. Only status :new and :loaded are valid to insert a new entity."
    )
  end

  defp insert_changeset(nil), do: nil

  defp insert_changeset_for_aspect(ch, entity, aspect) do
    sql_aspect = aspect.persistence()
    field_changes = Entity.fields_for(entity, aspect)
    assoc_changes = Entity.assocs_for(entity, aspect)

    case sql_aspect.persistence_method() do
      :table ->
        assoc_ch =
          struct(sql_aspect)
          |> Ecto.Changeset.change(field_changes)
          |> put_assocs_in_changeset(assoc_changes)

        Ecto.Changeset.put_assoc(ch, aspect.name(), assoc_ch)

      :embedded ->
        assoc_ch = Ecto.Changeset.change(sql_aspect, field_changes)

        Ecto.Changeset.put_embed(ch, aspect.name(), assoc_ch)
        |> put_assocs_in_changeset(assoc_changes)

      :fields ->
        Ecto.Changeset.change(ch, field_changes)
        |> put_assocs_in_changeset(assoc_changes)
    end
  end

  defp put_assocs_in_changeset(changeset, assoc_changes) do
    Enum.reduce(assoc_changes, changeset, fn
      {name, list}, ch when is_list(list) ->
        chs = for data <- list, do: insert_changeset(data)
        Ecto.Changeset.put_assoc(ch, name, chs)

      {name, data}, ch ->
        Ecto.Changeset.put_assoc(ch, name, insert_changeset(data))
    end)
  end

  defp from_entity_fields(entity) when APG.is_entity(entity) do
    entity
    |> Map.take([:"@context", :id, :type])
    |> Map.put(:local, Entity.local?(entity))
    |> Map.put(:extension_fields, Entity.extension_fields(entity))
  end

  @doc """
  Alex is not happy with this update functionality, because it does not work the same as inserting new `Entities`. Updates currently only work with fields and not with associations.

  The associations are more complex to handle correctly, for example, in Ecto you should preload all the entities or handle them manually with Changesets. So Alex opted for a simpler solution with `ActivityPub.SQL.Alter`.
  """
  def update(entity, changes) when APG.is_entity(entity) and APG.has_status(entity, :loaded) do
    with entity = ActivityPub.SQL.Query.preload_aspect(entity, :all),
         {:ok, entity} <- ActivityPub.Builder.update(entity, changes),
         {:ok, sql_entity} <- update_from_entity(entity) do
      {:ok, to_entity(sql_entity)}
    end
  end

  defp update_from_entity(entity)
       when APG.is_entity(entity) and APG.has_status(entity, :loaded) do
    sql_entity = Entity.persistence(entity)
    ch = Ecto.Changeset.change(sql_entity)

    ch =
      Entity.aspects(entity)
      |> Enum.reduce(ch, fn aspect, ch ->
        update_changeset_for_aspect(ch, entity, sql_entity, aspect)
      end)

    ch = Ecto.Changeset.change(ch, extension_fields: Entity.extension_fields(entity))

    Repo.update(ch)
  end

  defp update_changeset_for_aspect(ch, entity, sql_entity, aspect) do
    sql_aspect = aspect.persistence()
    fields = Entity.fields_for(entity, aspect)

    case sql_aspect.persistence_method() do
      :table ->
        assoc_ch =
          sql_entity
          |> Map.fetch!(aspect.name())
          |> Ecto.Changeset.change(fields)

        Ecto.Changeset.put_assoc(ch, aspect.name(), assoc_ch)

      :embedded ->
        assoc_ch =
          sql_entity
          |> Map.fetch!(aspect.name())
          |> Ecto.Changeset.change(fields)

        Ecto.Changeset.put_embed(ch, aspect.name(), assoc_ch)

      :fields ->
        Ecto.Changeset.change(ch, fields)
    end
  end

  def delete(entity, assocs \\ [])
  def delete(entity, assocs) when APG.is_entity(entity) and APG.has_status(entity, :loaded) do
    # FIXME this should be a transaction
    Enum.each(assocs, &delete_assoc(entity, &1))
    sql_entity = Entity.persistence(entity)
    # FIXME ?
    {:ok, _} = Repo.delete(sql_entity)
    :ok
  end

  defp delete_assoc(entity, assoc) do
    Query.new()
    |> Query.belongs_to(assoc, entity)
    |> Query.delete_all()
  end

  @doc """
  Converts an `SQLEntity` — which is an Ecto.Schema — back to a runtime `ActivityPub.Entity`.

  In this process, all of the `ActivityPub.SQLAspect`s are added as `ActivityPub.Aspect` in the `ActivityPub.Entity`, and the SQL associations are converted to `ActivityPub.Entity` fields.

  When you insert a new `ActivityPub.Entity`, the `SQLEntity` has the full information, all the _aspects_ and all the associations are loaded, so the returned `ActivityPub.Entity` is completely loaded.

  However, the process from _SQLEntity_ to `ActivityPub.Entity` also happens when loading an `ActivityPub.Entity` using a SQL Query. In this case, it is possible — and likely — that the `SQLEntity` is not fully loaded. A regular `SQLEntity` object has more than 10 "many to many" relations, to load all of them we need more than 10 double joins.

  In case an association is not preloaded in the `SQLEntity`, the final `ActivityPub.Entity` will have the `ActivityPub.SQL.AssociationNotLoaded` struct in the field value.

  It can also happen that a `ActivityPub.SQLAspect` is not preloaded in the _SQLEntity_, in this case the field is set to the `ActivityPub.SQL.FieldNotLoaded` struct.

  ### Note:_ ID_ of local entities is _null_

  The field/column _ID_ is an [ActivityPub ID](https://www.w3.org/TR/activitypub/#obj-id) (which means it is a URI), and is null (in the database) for local entities (originating from the local instance). At load-time, the null value is transformed into a URL in `calc_ap_id/1` using `ActivityPub.URLBuilder`.

  """
  def to_entity(%__MODULE__{} = sql_entity) do
    entity = %{
      __ap__: Metadata.load(sql_entity),
      id: calc_ap_id(sql_entity),
      "@context": Map.fetch!(sql_entity, :"@context"),
      type: sql_entity.type
    }

    aspects = Entity.aspects(entity)

    sql_entity
    |> load_fields(aspects)
    |> Map.merge(load_assocs(sql_entity, aspects))
    |> Map.merge(sql_entity.extension_fields)
    |> Map.merge(entity)
  end

  def to_entity(sql_entities) when is_list(sql_entities),
    do: Enum.map(sql_entities, &to_entity/1)

  def to_entity(nil), do: nil

  defp calc_ap_id(%__MODULE__{local: true, local_id: local_id}), do: UrlBuilder.id(local_id)
  defp calc_ap_id(%__MODULE__{id: id}), do: id

  defp load_fields(%__MODULE__{} = sql_entity, aspects) do
    Enum.reduce(aspects, %{}, fn aspect, acc ->
      case get_sql_data_for_aspect_fields(sql_entity, aspect) do
        %Ecto.Association.NotLoaded{} ->
          aspect.__aspect__(:fields)
          |> Enum.into(acc, &{&1, %FieldNotLoaded{}})

        sql_data ->
          sql_data
          |> Map.take(aspect.__aspect__(:fields))
          |> Map.merge(acc)
      end
    end)
  end

  defp load_assocs(%__MODULE__{} = sql_entity, aspects) do
    Enum.reduce(aspects, %{}, fn aspect, acc ->
      sql_aspect = aspect.persistence()

      case get_sql_data_for_aspect_assocs(sql_entity, aspect) do
        %Ecto.Association.NotLoaded{} ->
          sql_aspect.__sql_aspect__(:associations)
          |> Enum.into(acc, fn sql_assoc ->
            {sql_assoc.name,
             %AssociationNotLoaded{
               sql_assoc: sql_assoc,
               sql_aspect: sql_aspect
             }}
          end)

        sql_data ->
          sql_aspect.__sql_aspect__(:associations)
          |> Enum.reduce(acc, fn sql_assoc, acc ->
            assoc_name = sql_assoc.name

            case Map.fetch!(sql_data, assoc_name) do
              %Ecto.Association.NotLoaded{} ->
                local_id = not_loaded_assoc_local_id(sql_assoc, sql_data)

                Map.put(acc, assoc_name, %AssociationNotLoaded{
                  sql_assoc: sql_assoc,
                  sql_aspect: sql_aspect,
                  local_id: local_id
                })

              value ->
                Map.put(acc, assoc_name, to_entity(value))
            end
          end)
      end
    end)
  end

  defp not_loaded_assoc_local_id(%ActivityPub.SQL.Associations.Collection{name: name}, sql_data) do
    key = String.to_atom("#{name}_id")
    Map.get(sql_data, key)
  end

  defp not_loaded_assoc_local_id(_, _), do: nil

  defp get_sql_data_for_aspect_fields(%__MODULE__{} = sql_entity, aspect) do
    aspect.persistence().persistence_method()
    |> case do
      x when x in [:table, :embedded] ->
        Map.fetch!(sql_entity, aspect.name())

      :fields ->
        sql_entity
    end
  end

  defp get_sql_data_for_aspect_assocs(%__MODULE__{} = sql_entity, aspect) do
    aspect.persistence().persistence_method()
    |> case do
      x when x in [:fields, :embedded] ->
        sql_entity

      :table ->
        Map.fetch!(sql_entity, aspect.name())
    end
  end
end
