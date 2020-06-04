# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Taxonomy.Tag do
  use MoodleNet.Common.Schema

  alias Ecto.Changeset
  alias Taxonomy.Tag


  @type t :: %__MODULE__{}
  @required ~w(label)a
  @cast @required ++ ~w(description parent_tag_id character_id)a


  @primary_key{:id, :id, autogenerate: true}
  schema "taxonomy_tags" do
    # field(:id, :string)
    field(:label, :string)
    field(:description, :string)
    # field(:parent_tag_id, :integer)
    belongs_to(:parent_tag, Tag, type: :id)
    belongs_to(:character, Character, type: Ecto.ULID)
  end

  def update_changeset(
      %Tag{} = tag,
      %{id: _} = character,
      attrs
    ) do
      tag
      |> Changeset.cast(attrs, @cast)
      |> Changeset.change(
        character_id: character.id
      )
      |> common_changeset()
  end

  def update_changeset(%Tag{} = tag, attrs) do
    tag
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
    # |> change_public()
    # |> change_disabled()
  end


end
