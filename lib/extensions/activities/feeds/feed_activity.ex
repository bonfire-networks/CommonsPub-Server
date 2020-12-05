# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Feeds.FeedActivity do
  use CommonsPub.Repo.Schema
  alias CommonsPub.Activities.Activity
  alias CommonsPub.Feeds.Feed

  table_schema "mn_feed_activity" do
    belongs_to(:feed, Feed)
    belongs_to(:activity, Activity)
  end
end
