# SPDX-License-Identifier: AGPL-3.0-only
defmodule Organisation do
  use CommonsPub.Common.Schema

  use Pointers.Pointable,
    otp_app: :commons_pub,
    source: "organisation",
    table_id: "C1RC1E0FPE0P1EAND0RC1RC1ES"

  import CommonsPub.Common.Changeset, only: [change_public: 1, change_disabled: 1]

  alias Ecto.Changeset
  alias Organisation
  # alias CommonsPub.Characters.Character
  alias Pointers.Pointer
  alias CommonsPub.Characters.Character

  @type t :: %__MODULE__{}

  pointable_schema do
    # joined fields from profile
    field(:name, :string, virtual: true)
    field(:summary, :string, virtual: true)
    field(:updated_at, :utc_datetime_usec, virtual: true)

    # mixins
    has_one(:profile, CommonsPub.Profiles.Profile, foreign_key: :id)
    has_one(:character, CommonsPub.Characters.Character, foreign_key: :id)

    # joined via character
    # has_one(:actor, Actor, foreign_key: :id)

    # points to the parent thing of this character
    belongs_to(:context, Pointer)

    # joined fields from Actor:
    field(:preferred_username, :string, virtual: true)
    field(:canonical_url, :string, virtual: true)

    field(:extra_info, :map)
  end

  @cast ~w(extra_info)a

  def create_changeset(
        %{id: _} = context,
        attrs
      ) do
    %Organisation{}
    # |> Changeset.change(
    #   id: Ecto.ULID.generate()
    #   )
    |> Changeset.cast(attrs, @cast)
    |> Changeset.change(context_id: context.id)
    |> common_changeset()
  end

  def create_changeset(attrs) do
    %Organisation{}
    # |> Changeset.change(
    #   id: Ecto.ULID.generate()
    #   )
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  def update_changeset(%Organisation{} = organisation, attrs) do
    organisation
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    |> change_public()
    |> change_disabled()
  end

  ### behaviour callbacks

  def context_module, do: Organisation.Organisations

  def queries_module, do: Organisation.Queries

  def follow_filters, do: [:default]
end
