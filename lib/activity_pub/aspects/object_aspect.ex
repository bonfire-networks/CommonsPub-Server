defmodule ActivityPub.ObjectAspect do
  use Ecto.Schema

  alias ActivityPub.{LanguageValueType, StringListType, EntityType}

  @primary_key false
  embedded_schema do
    field(:attachment, EntityType, default: [])
    field(:attributed_to, EntityType, default: [])
    field(:audience, EntityType, default: [])
    field(:content, LanguageValueType, default: %{})
    field(:context, EntityType, default: [])
    field(:name, LanguageValueType, default: %{})
    field(:end_time, :utc_datetime)
    field(:generator, EntityType, default: [])
    field(:icon, EntityType, default: [])
    field(:image, EntityType, default: [])
    field(:in_reply_to, EntityType, default: [])
    field(:location, EntityType, default: [])
    field(:preview, EntityType, default: [])
    field(:published, :utc_datetime)
    field(:replies, EntityType, default: [])
    field(:start_time, :utc_datetime)
    field(:summary, LanguageValueType, default: %{})
    field(:tag, EntityType, default: [])
    field(:updated, :utc_datetime)
    # FIXME url is a relation
    # field(:url, EntityType, default: [])
    field(:url, StringListType, default: [])
    field(:to, StringListType, default: [])
    field(:bto, StringListType, default: [])
    field(:cc, StringListType, default: [])
    field(:bcc, StringListType, default: [])
    field(:media_type, :string)
    field(:duration , :string)
  end

  def parse(%{} = input) do
    %__MODULE__{}
    |> Ecto.Changeset.cast(input, __MODULE__.__schema__(:fields))
    |> Ecto.Changeset.apply_action(:insert)
  end

  def internal_field(), do: :object
end
