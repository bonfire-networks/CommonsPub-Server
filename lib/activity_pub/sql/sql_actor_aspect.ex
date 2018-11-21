defmodule ActivityPub.SQLActorAspect do
  use Ecto.Schema

  alias ActivityPub.{Entity, SQLObject, UrlBuilder}

  @primary_key {:local_id, :id, autogenerate: true}
  schema "activity_pub_actor_aspects" do
    field(:inbox, :string)
    field(:outbox, :string)
    field(:following, :string)
    field(:followers, :string)
    field(:liked, :string)
    field(:preferred_username, :string)
    field(:streams, {:map, :string})
    field(:endpoints, {:map, :string})

    field(:followers_count, :integer, default: 0)
    field(:following_count, :integer, default: 0)

    timestamps()
  end

  def create_changeset(_sql_object, %Entity{actor: nil}), do: nil

  def create_changeset(%SQLObject{local_id: local_id} = obj, %Entity{actor: actor_aspect}) do
    changes = Map.take(actor_aspect, __MODULE__.__schema__(:fields))
    %__MODULE__{}
    |> Ecto.Changeset.change(changes)
    |> Ecto.Changeset.change(local_id: local_id)
    |> set_urls(obj)
  end

  defp set_urls(ch, %SQLObject{local: false}), do: ch
  defp set_urls(ch, %SQLObject{local: true, id: id}) do
    Ecto.Changeset.change(ch, UrlBuilder.actor_urls(id))
  end

  def to_aspect(nil), do: nil
  def to_aspect(%__MODULE__{} = s) do
    {:ok, a} = ActivityPub.ActorAspect.parse(Map.from_struct(s))
    a
  end
end
