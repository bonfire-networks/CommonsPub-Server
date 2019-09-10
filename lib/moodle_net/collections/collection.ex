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
    field :public, :boolean
    field :icon, :string # todo: reference the images table when we have one
    field :primary_language, :string
    belongs_to :creator, User
    belongs_to :collection, Community
    has_many :threads, Thread
    timestamps()
  end

  @required_attrs [:local, :name, :preferred_username, :summary, :primary_language]
  @optional_attrs []
  @cast_attrs @required_attrs ++ @optional_attrs
  
  def changeset(collection \\ %Collection{}, attrs)
  def changeset(%Collection{}=collection, attrs) when is_map(attrs) do
    collection
    |> Changeset.cast(attrs, @cast_attrs)
    |> Changeset.validate_required(@required_attrs)
  end

end
