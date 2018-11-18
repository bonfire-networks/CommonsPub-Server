defmodule ActivityPub.CollectionAspect do
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field(:total_items, :integer)
    # FIXME make just single
    field(:current, ActivityPub.EntityType, default: [])
    field(:first, ActivityPub.EntityType, default: [])
    field(:last, ActivityPub.EntityType, default: [])
    field(:items, ActivityPub.EntityType, default: [])

    field(:__ordered__, :boolean)
  end

  @fields [:current, :first, :last, :items]

  def parse(%{} = input) do
    %__MODULE__{}
    |> Ecto.Changeset.cast(input, @fields)
    |> Ecto.Changeset.apply_action(:insert)
  end

  def internal_field(), do: :collection
end
