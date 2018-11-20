defmodule ActivityPub.SQLObject do
  use Ecto.Schema

  alias ActivityPub.Entity

  alias ActivityPub.{
    ObjectAspect,
    ActorAspect,
    ActivityAspect,
    CollectionAspect
  }

  alias ActivityPub.{
    SQLObjectAspect,
    SQLActorAspect,
    SQLActivityAspect,
    SQLCollectionAspect
  }

  alias ActivityPub.{LanguageValueType, StringListType, EntityType}

  @primary_key {:local_id, :id, autogenerate: true}
  schema "activity_pub_objects" do
    field(:"@context", :map)
    field(:id, :string)
    field(:type, StringListType)

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

    timestamps()
  end

  def create_changeset(entity) do
    changes =
      entity
      |> take_entity_fields()
      |> Map.merge(take_object_fields(entity.object))

    Ecto.Changeset.change(%__MODULE__{}, changes)
  end

  defp take_entity_fields(map) do
    Map.take(map, [:"@context", :id, :type])
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
    {:ok, a} = ObjectAspect.parse(Map.from_struct(sql))
    a
  end
end
