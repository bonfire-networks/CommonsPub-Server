# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Communities.Community do
  use Ecto.Schema
  alias Ecto.Changeset
  alias MoodleNet.Users.User
  alias MoodleNet.Communities.{Community, Member, Thread}
  alias MoodleNet.Collections.Collection
  
  schema "mn_community" do
    field :local, :boolean
    field :name, :string
    field :preferred_username, :string
    field :summary, :string
    field :icon, :string # todo: reference the images table when we have one
    field :primary_language, :string
    belongs_to :creator, User
    has_many :collections, Collection
    has_many :threads, Thread
    has_many :members, Member
    timestamps()
  end
p
  @required_attrs [:local, :name, :preferred_username, :summary, :primary_language]
  @optional_attrs [:creator]
  @cast_attrs @required_attrs ++ @optional_attrs
  
  def changeset(community \\ %Community{}, attrs)
  def changeset(%Community{}=community, attrs) when is_map(attrs) do
    community
    |> Changeset.cast(attrs, @cast_attrs)
    |> Changeset.validate_required(@required_attrs)
    |> Changeset.unique_constraint(:preferred_username)
  end

end
