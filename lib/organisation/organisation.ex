# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Organisation do
  use MoodleNet.Common.Schema

  import MoodleNet.Common.Changeset, only: [change_public: 1, change_disabled: 1]

  alias Ecto.Changeset
  alias Organisation
  alias Character
  alias MoodleNet.Feeds.Feed
  alias MoodleNet.Users.User
  alias MoodleNet.Uploads.Content
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Actors.Actor

  @type t :: %__MODULE__{}

  table_schema "mn_organisation" do
    
    belongs_to(:character, Character)

    # joined fields from Character
    field(:name, :string, virtual: true) 
    field(:summary, :string, virtual: true) 
    field(:updated_at, :utc_datetime_usec, virtual: true)
    
    has_one(:actor, Actor) # joined via Character
    
    # joined fields from Actor:
    field(:preferred_username, :string, virtual: true) 
    field(:canonical_url, :string, virtual: true) 
    
    field(:extra_info, :map)
  end

  @cast ~w(extra_info)a

  def create_changeset(
      %Character{} = character,
      attrs
    ) do
  %Organisation{}
  |> Changeset.change(
    character_id: character.id
    )
  |> common_changeset()
  end

  def update_changeset(%Organisation{} = organisation, attrs) do
    organisation
    |> Changeset.cast(attrs, @cast)
    |> common_changeset()
  end

  defp common_changeset(changeset) do
    changeset
  end


  ### behaviour callbacks

  def context_module, do: Organisation.Organisations

  def queries_module, do: Organisation.Queries

  def follow_filters, do: [:default]

end
