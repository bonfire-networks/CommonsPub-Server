# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Likes.LikeCount do
  use Bonfire.Repo.Schema
  alias CommonsPub.Users.User

  view_schema "mn_like_count" do
    belongs_to(:creator, User, primary_key: true)
    field(:count, :integer)
  end
end
