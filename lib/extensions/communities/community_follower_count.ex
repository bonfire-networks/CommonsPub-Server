# SPDX-License-Identifier: AGPL-3.0-only

defmodule CommonsPub.Communities.CommunityFollowerCount do
  use CommonsPub.Repo.Schema
  alias CommonsPub.Communities.Community

  view_schema "mn_community_follower_count" do
    belongs_to(:community, Community, primary_key: true)
    field(:count, :integer)
  end
end
