# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Feeds.FeedSubscription do

  use MoodleNet.Common.Schema
  import MoodleNet.Common.Changeset, only: [change_synced_timestamps: 4]
  alias Ecto.Changeset
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

  @create_cast ~w(is_active)a
  @create_required @create_cast

  def create_changeset(subscriber_id, feed_id, %{}=attrs)
  when is_binary(subscriber_id) and is_binary(feed_id) do
    %__MODULE__{}
    |> Changeset.cast(attrs, @create_cast)
    |> Changeset.validate_required(@create_required)
    |> Changeset.change(subscriber_id: subscriber_id, feed_id: feed_id)
    |> change_synced_timestamps(:is_active, :activated_at, :disabled_at)
  end

  @update_cast ~w(is_active)a

  def update_changeset(%__MODULE__{}=sub, %{}=attrs) do
    sub
    |> Changeset.cast(attrs, @update_cast)
    |> change_synced_timestamps(:is_active, :activated_at, :disabled_at)
  end

end
