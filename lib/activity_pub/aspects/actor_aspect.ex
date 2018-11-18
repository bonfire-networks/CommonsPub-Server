defmodule ActivityPub.ActorAspect do
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field(:inbox, :string)
    field(:outbox, :string)
    field(:following, :string)
    field(:followers, :string)
    field(:liked, :string)
    field(:preferred_username, :string)
    field(:streams, {:map, :string})
    field(:endpoints, {:map, :string})
  end

  @fields [:inbox, :outbox, :following, :followers, :liked, :preferred_username, :streams, :endpoints]
  def parse(%{} = input) do
    %__MODULE__{}
    |> Ecto.Changeset.cast(input, @fields)
    |> Ecto.Changeset.apply_action(:insert)
  end

  def internal_field(), do: :actor
end
