# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Feeds.FeedSubscription do

  use MoodleNet.Common.Schema
  alias Ecto.Changeset
  alias MoodleNet.Activities.Activity
  alias MoodleNet.Meta.Pointer
  alias MoodleNet.Feeds.Feed

  table_schema "mn_feed_subscription" do
    belongs_to :subscriber, Pointer
    belongs_to :feed, Feed
    field(:is_active, :boolean, virtual: true)
    field(:activated_at, :utc_datetime_usec)
    field(:disabled_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)
    timestamps()
  end

  def create_changeset(%{id: subscriber_id}, feed_id, %{}=attrs)
  when is_binary(subscriber_id) and is_binary(feed_id) do
    
    
  end
end
