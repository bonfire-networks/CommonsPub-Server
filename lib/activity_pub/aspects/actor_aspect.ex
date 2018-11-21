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

    field(:followers_count, :integer, default: 0)
    field(:following_count, :integer, default: 0)
  end

  def parse(%{} = input) do
    %__MODULE__{}
    |> Ecto.Changeset.cast(input, __MODULE__.__schema__(:fields))
    |> Ecto.Changeset.apply_action(:insert)
  end

  def internal_field(), do: :actor
end
