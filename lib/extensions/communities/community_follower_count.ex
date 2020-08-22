# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Communities.CommunityFollowerCount do
  use MoodleNet.Common.Schema
  alias MoodleNet.Communities.Community

  view_schema "mn_community_follower_count" do
    belongs_to(:community, Community, primary_key: true)
    field(:count, :integer)
  end
end
