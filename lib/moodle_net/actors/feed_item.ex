# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Actors.FeedItem do
  use Ecto.Schema
  alias Ecto.Changeset
  alias MoodleNet.Actors.{Actor,FeedItem}

  schema "mn_actor_feed_items" do
    belongs_to :actor, Actor
    field :item_type, :string
    timestamps()
  end

  @item_types []
  @cast_attrs []
  @required_attrs []

  def changeset(%FeedItem{}=feed_item, attrs) do
    feed_item
    |> Changeset.cast(attrs, @cast_attrs)
    |> Changeset.validate_required(@required_attrs)
  end

end
