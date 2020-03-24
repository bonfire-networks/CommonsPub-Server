# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Repo do
  @moduledoc """
  MoodleNet main Ecto Repo
  """

  use Ecto.Repo,
    otp_app: :moodle_net,
    adapter: Ecto.Adapters.Postgres
  import Ecto.Query
  alias MoodleNet.Common.NotFoundError

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end

  @doc """
  Like Repo.one, but returns an ok/error tuple.
  """
  def single(q) do
    case one(q) do
      nil -> {:error, NotFoundError.new()}
      other -> {:ok, other}
    end
  end

  @doc "Like Repo.get, but returns an ok/error tuple"
  @spec fetch(atom, integer | binary) :: {:ok, atom} | {:error, NotFoundError.t()}
  def fetch(queryable, id) do
    case get(queryable, id) do
      nil -> {:error, NotFoundError.new()}
      thing -> {:ok, thing}
    end
  end

  @doc "Like Repo.get_by, but returns an ok/error tuple"
  def fetch_by(queryable, term) do
    case get_by(queryable, term) do
      nil -> {:error, NotFoundError.new()}
      thing -> {:ok, thing}
    end
  end

  def fetch_all(queryable, ids) when is_binary(ids) do
    queryable
    |> where([t], t.id in ^ids)
    |> all()
  end

  @doc """
  Run a transaction, similar to `Repo.transaction/1`, but it expects an ok or error
  tuple. If an error tuple is returned, the transaction is aborted.
  """
  @spec transact_with(fun :: (-> {:ok, any} | {:error, any})) :: {:ok, any} | {:error, any}
  def transact_with(fun) do
    transaction(fn ->
      case fun.() do
        {:ok, v} -> v
        {:error, reason} -> rollback(reason)
      end
    end)
  end

  def transact_many([]), do: {:ok, []}
  def transact_many(queries) when is_list(queries) do
    transaction(fn -> Enum.map(queries, &transact/1) end)
  end

  defp transact({:all, q}), do: all(q)
  defp transact({:count, q}), do: aggregate(q, :count)
  defp transact({:one, q}), do: one(q)
  defp transact({:one!, q}) do
    {:ok, ret} = single(q)
    ret
  end
end
