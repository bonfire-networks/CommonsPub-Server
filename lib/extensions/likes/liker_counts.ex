# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.Likes.LikerCounts do
  alias CommonsPub.Repo
  alias Bonfire.GraphQL.Fields
  alias CommonsPub.Likes.{LikerCount, LikerCountsQueries}

  def one(filters), do: Repo.single(LikerCountsQueries.query(LikerCount, filters))

  def many(filters \\ []) do
    {:ok, Repo.all(LikerCountsQueries.query(LikerCount, filters))}
  end

  def fields(group_fn, filters \\ [])
      when is_function(group_fn, 1) do
    {:ok, fields} = many(filters)
    {:ok, Fields.new(fields, group_fn)}
  end
end
