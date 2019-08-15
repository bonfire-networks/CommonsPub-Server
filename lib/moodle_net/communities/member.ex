# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Communities.Member do
  use Ecto.Schema
  alias Ecto.Changeset
  alias MoodleNet.Users.User
  alias MoodleNet.Communities.{Community, Member, Thread}
  alias MoodleNet.Collections.Collection
  
  schema "mn_community_member" do
    belongs_to :user, User
    belongs_to :community, Community
    timestamps()
  end

  @required_attrs [:user_id, :community_id]
  @cast_attrs @required_attrs
  
  def changeset(community \\ %Community{}, attrs)
  def changeset(%Community{}=community, attrs) when is_map(attrs) do
    community
    |> Changeset.cast(attrs, @cast_attrs)
    |> Changeset.validate_required(@required_attrs)
    |> Changeset.unique_constraint([:user_id, :community_id])
  end

end
