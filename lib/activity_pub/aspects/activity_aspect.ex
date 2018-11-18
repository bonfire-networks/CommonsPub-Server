defmodule ActivityPub.ActivityAspect do
  use Ecto.Schema

  @primary_key false

  embedded_schema do
    field(:actor, ActivityPub.EntityType, default: [])
    field(:object, ActivityPub.EntityType, default: [])
    field(:target, ActivityPub.EntityType, default: [])
  end

  def parse(%{} = input) do
    %__MODULE__{}
    |> Ecto.Changeset.cast(input, [:actor, :object, :target])
    |> Ecto.Changeset.apply_action(:insert)
  end

  def internal_field(), do: :activity
end
