defmodule ActivityPub.CollectionPageAspect do
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    # FIXME make just single
    field(:part_of, ActivityPub.EntityType, default: [])
    field(:next, ActivityPub.EntityType, default: [])
    field(:prev, ActivityPub.EntityType, default: [])
  end

  @fields [:part_of, :next, :prev]

  def parse(%{} = input) do
    %__MODULE__{}
    |> Ecto.Changeset.cast(input, @fields)
    |> Ecto.Changeset.apply_action(:insert)
  end

  def internal_field(), do: :collection_page
end

