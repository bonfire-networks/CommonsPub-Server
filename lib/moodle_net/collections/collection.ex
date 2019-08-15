# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Collections.Collection do
  use Ecto.Schema
  alias Ecto.Changeset
  alias MoodleNet.Users.User
  alias MoodleNet.Communities.Community
  alias MoodleNet.Collections.{Collection, Thread}

  schema "mn_collection" do
    field :local, :boolean
    field :name, :string
    field :summary, :string
    field :content, :string
    field :icon, :string # todo: reference the images table when we have one
    field :primary_language, :string
    belongs_to :creator, User
    belongs_to :collection, Collection
    has_many :threads, Thread
    timestamps()
  end

  @required_attrs [
    :local, :name, :preferred_username,
    :summary, :content, :primary_language,
  ]
  @optional_attrs [:creator_id]
  @cast_attrs @required_attrs ++ @optional_attrs
  
  def changeset(community \\ %Community{}, attrs)
  def changeset(%Community{}=community, attrs) when is_map(attrs) do
    community
    |> Changeset.cast(attrs, @cast_attrs)
    |> Changeset.validate_required(@required_attrs)
    |> Changeset.unique_constraint(:preferred_username)
  end

end
