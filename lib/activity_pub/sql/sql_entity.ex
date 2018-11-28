defmodule ActivityPub.SQLEntity do
  use Ecto.Schema
  alias Ecto.Multi
  require ActivityPub.Guards, as: APG

  alias ActivityPub.Entito, as: Entity
  alias ActivityPub.{SQLAspect, UrlBuilder}

  @primary_key {:local_id, :id, autogenerate: true}
  schema "activity_pub_objects" do
    # field(:local_id, :integer, primary_key: true)
    field(:id, :string)
    field(:"@context", :map)
    field(:type, {:array, :string})
    field(:local, :boolean, default: false)
    field(:extension_fields, :map, default: %{})

    timestamps()

    for sql_aspect <- SQLAspect.all() do
      aspect = sql_aspect.aspect()
      has_one(aspect.name(), sql_aspect, foreign_key: :local_id)
    end
  end

  def persist(entity) when APG.is_entity(entity) do
    Multi.new()
    |> Multi.insert(:_entity, create_changeset(entity))
    |> Multi.run(:entity, &set_ap_id/2)
    |> MoodleNet.Repo.transaction()
  end

  defp create_changeset(entity) do
    ch = %__MODULE__{}
    |> Ecto.Changeset.change(take_entity_fields(entity))

    Entity.aspects(entity)
    |> Enum.reduce(ch, fn aspect, ch ->
      aspect_ch = aspect.persistence().create_changeset(entity)
      Ecto.Changeset.put_assoc(ch, aspect.name(), aspect_ch)
    end)
  end

  defp take_entity_fields(map) do
    # , :local, :extension_fields])
    Map.take(map, [:"@context", :id, :type, :local_id])
  end

  def set_ap_id(repo, %{_entity: %{id: nil, local_id: local_id} = e}) do
    id = UrlBuilder.id(local_id)

    e
    |> Ecto.Changeset.change(id: id, local: true)
    |> repo.update()
  end

  def set_ap_id(_repo, %{_entity: %{id: id} = e}) when not is_nil(id),
    do: {:ok, e}
end
