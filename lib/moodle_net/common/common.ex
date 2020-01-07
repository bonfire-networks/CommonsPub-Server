# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Common do
  alias MoodleNet.{Activities, Feeds, Meta, Repo}
  alias MoodleNet.Common.{
    AlreadyFollowingError,
    AlreadyLikedError,
    Block,
    DeletionError,
    Feature,
    Follow,
    Like,
    Query,
    Tag
  }

  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Access.NotPermittedError
  alias MoodleNet.Common.{Changeset, NotFoundError}
  alias MoodleNet.Users.User
  import Ecto.Query

  ### pagination

  def paginate(query, opts), do: query

  defp cursor_or_id(%{cursor: cursor}), do: cursor
  defp cursor_or_id(%{id: id}), do: id
  
  def page_info(results, id \\ &cursor_or_id/1) when is_list(results) do
    case results do
      [] -> nil
      [x] -> %{start_cursor: id.(x), end_cursor: id.(x)}
      [x | xs] -> %{start_cursor: id.(x), end_cursor: id.(List.last(xs))}
    end
  end

  # @doc "Optionally paginates a query according to a user's request"
  # def paginate(query, opts) do
  # end

  # defp paginate_before(query, nil), do: {:ok, query}

  # defp paginate_before(query, offset)
  # when is_integer(offset) and offset >= 0, do: {:ok, offset(query, ^offset)}

  # defp paginate_before_q(query) do
  #   where(q, [
  # end

  # defp paginate_limit(query, nil), do: {:ok, query}

  # defp paginate_limit(query, limit)
  # when is_integer(limit) and limit >= 0 and limit <= 100,
  #   do: {:ok, limit(query, ^limit)}

  # defp paginate_limit(query, limit)


  ## Deletion

  @spec soft_delete(any()) :: {:ok, any()} | {:error, DeletionError.t()}
  @doc "Marks an entry as deleted in the database"
  def soft_delete(it), do: deletion_result(do_soft_delete(it))

  @spec soft_delete!(any()) :: any()
  @doc "Marks an entry as deleted in the database or throws a DeletionError"
  def soft_delete!(it), do: deletion_result!(do_soft_delete(it))

  defp do_soft_delete(it), do: Repo.update(Changeset.soft_delete_changeset(it))

  @spec hard_delete(any()) :: {:ok, any()} | {:error, DeletionError.t()}
  @doc "Deletes an entry from the database"
  def hard_delete(it) do
    it
    |> Repo.delete(
      stale_error_field: :id,
      stale_error_message: "has already been deleted"
    )
    |> deletion_result()
  end

  @spec hard_delete!(any()) :: any()
  @doc "Deletes an entry from the database, or throws a DeletionError"
  def hard_delete!(it),
    do: deletion_result!(hard_delete(it))

  def deletion_result({:error, e}), do: {:error, DeletionError.new(e)}
  def deletion_result(other), do: other

  def deletion_result!({:ok, val}), do: val
  def deletion_result!({:error, e}), do: throw(e)
end
