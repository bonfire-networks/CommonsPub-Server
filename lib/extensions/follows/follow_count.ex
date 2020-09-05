# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Follows.FollowCount do
  use CommonsPub.Common.Schema
  alias CommonsPub.Users.User

  view_schema "mn_follow_count" do
    belongs_to(:creator, User, primary_key: true)
    field(:count, :integer)
  end
end
