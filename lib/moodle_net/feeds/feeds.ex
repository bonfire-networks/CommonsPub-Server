# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Feeds do

  alias MoodleNet.Feeds.{Feed, FeedActivity, FeedSubscription, Queries}
  alias MoodleNet.Meta.TableService
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Flags.Flag
  alias MoodleNet.Follows.Follow
  alias MoodleNet.Likes.Like
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Repo
  alias MoodleNet.Threads.Comment
  alias Ecto.ULID
  import Ecto.Query
  
  def instance_outbox_id(), do: "10CA11NSTANCE00TB0XFEED1D0"
  def instance_inbox_id(),  do: "10CA11NSTANCE1NB0XFEED1D00"

  @doc """
  Retrieves a single feed by arbitrary filters.
  Used by:
  * GraphQL Item queries
  * ActivityPub integration
  * Various parts of the codebase that need to query for communities (inc. tests)
  """
  def one(filters), do: Repo.single(Queries.query(Feed, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Feed, filters))}

  def create(), do: Repo.insert(Feed.create_changeset())

end
