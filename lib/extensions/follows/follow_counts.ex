# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Follows.FollowCounts do
  alias CommonsPub.Repo
  alias CommonsPub.Follows.{FollowCount, FollowCountsQueries}
  alias Bonfire.GraphQL.Fields

  def one(filters), do: Repo.single(FollowCountsQueries.query(FollowCount, filters))

  def many(filters \\ []) do
    {:ok, Repo.all(FollowCountsQueries.query(FollowCount, filters))}
  end

  def fields(group_fn, filters \\ [])
      when is_function(group_fn, 1) do
    {:ok, fields} = many(filters)
    Fields.new(fields, group_fn)
  end
end
