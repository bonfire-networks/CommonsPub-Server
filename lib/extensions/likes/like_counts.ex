# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Likes.LikeCounts do
  alias CommonsPub.Repo
  alias CommonsPub.GraphQL.Fields
  alias CommonsPub.Likes.{LikeCount, LikeCountsQueries}

  def one(filters), do: Repo.single(LikeCountsQueries.query(LikeCount, filters))

  def many(filters \\ []) do
    {:ok, Repo.all(LikeCountsQueries.query(LikeCount, filters))}
  end

  def fields(group_fn, filters \\ [])
      when is_function(group_fn, 1) do
    {:ok, fields} = many(filters)
    {:ok, Fields.new(fields, group_fn)}
  end
end
