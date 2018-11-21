defmodule ActivityPub.SQLObject do
  use Ecto.Schema

  alias ActivityPub.{Entity, UrlBuilder}

  alias ActivityPub.{
    ObjectAspect,
    ActorAspect,
    ActivityAspect,
    CollectionAspect
  }

  alias ActivityPub.{
    SQLObject,
    SQLActorAspect,
    SQLActivityAspect,
    SQLCollectionAspect,
    SQL.ObjectToObject
  }

  alias ActivityPub.{LanguageValueType, StringListType, EntityType}

  @primary_key {:local_id, :id, autogenerate: true}

  schema "activity_pub_objects" do
    field(:"@context", :map)
    field(:id, :string)
    field(:type, StringListType)
    field(:local, :boolean)

    has_one(:actor, SQLActorAspect, foreign_key: :local_id)
    # has_one(:activity, SQLActorAspect, foreign_key: :local_id)

    field(:content, LanguageValueType, default: %{})
    field(:name, LanguageValueType, default: %{})
    field(:end_time, :utc_datetime)
    field(:published, :utc_datetime)
    field(:start_time, :utc_datetime)
    field(:summary, LanguageValueType, default: %{})
    field(:updated, :utc_datetime)
    field(:to, StringListType, default: [])
    field(:bto, StringListType, default: [])
    field(:cc, StringListType, default: [])
    field(:bcc, StringListType, default: [])
    field(:media_type, :string)
    field(:duration, :string)

    field(:extension_fields, :map)

    many_to_many(:attributed_to, SQLObject,
      join_through: "activity_pub_attributed_tos",
      join_keys: [subject_id: :local_id, object_id: :local_id]
    )

    timestamps()
  end

  def create_changeset(%Entity{} = entity) do
    %__MODULE__{}
    |> Ecto.Changeset.change(take_entity_fields(entity))
    |> Ecto.Changeset.change(take_object_fields(entity.object))
    |> put_assocs(entity)
  end

  defp put_assocs(ch, entity) do
    ch
    |> Ecto.Changeset.put_assoc(:attributed_to, put_attributed_to(entity))
  end

  defp put_attributed_to(entity) do
    for assoc <- entity[:attributed_to], assoc.metadata.sql, do: assoc.metadata.sql
  end

  def set_id_changeset(%__MODULE__{local_id: local_id} = o) do
    Ecto.Changeset.change(o, id: UrlBuilder.id(local_id), local: true)
  end

  defp take_entity_fields(map) do
    Map.take(map, [:"@context", :id, :type, :local, :local_id, :extension_fields])
  end

  defp take_object_fields(map) do
    f = [
      :content,
      :name,
      :end_time,
      :published,
      :start_time,
      :summary,
      :updated,
      :to,
      :bto,
      :cc,
      :bcc,
      :media_type,
      :duration,
      :extension_fields
    ]

    Map.take(map, f)
  end

  def to_aspect(%__MODULE__{} = sql) do
    {:ok, a} =
      sql
      |> Map.take(__MODULE__.__schema__(:fields))
      |> ObjectAspect.parse()
    a
  end
end
