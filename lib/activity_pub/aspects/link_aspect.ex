defmodule ActivityPub.LinkAspect do
  use Ecto.Schema

  @primary_key false
  embedded_schema do
    field(:href, :string)
    field(:rel, :string)
    field(:media_type, :string)
    field(:name, :string)
    field(:hreflang, :string)
    field(:height, :string)
    field(:width, :string)
    field(:preview, :string)
  end

  def parse(%{} = input) do
    %__MODULE__{}
    |> Ecto.Changeset.cast(input, __MODULE__.__schema__(:fields))
    |> Ecto.Changeset.apply_action(:insert)
  end

  def internal_field(), do: :link
end
