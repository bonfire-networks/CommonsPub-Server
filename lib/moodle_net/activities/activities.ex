# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Activities do

  alias MoodleNet.{Common, Repo}
  alias MoodleNet.Activities.{Activity, Queries}
  alias MoodleNet.Batching.EdgesPage
  alias MoodleNet.Users.User

  def one(filters \\ []), do: Repo.single(Queries.query(Activity, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Activity, filters))}

  @doc """
  Retrieves an EdgesPage of feed activities according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def edges_page(cursor_fn, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def edges_page(cursor_fn, base_filters, data_filters, count_filters)
  when is_function(cursor_fn, 1) do
    {data_q, count_q} = Queries.queries(Activity, base_filters, data_filters, count_filters)
    with {:ok, [data, count]} <- Repo.transact_many(all: data_q, count: count_q) do
      {:ok, EdgesPage.new(data, count, cursor_fn)}
    end
  end

  @doc """
  Create a new activity related to any context that participates in the meta
  abstraction.
  """
  @spec create(User.t(), %{context_id: binary}, map) :: {:ok, Activity.t()} | {:error, Changeset.t()}
  def create(creator, context, %{}=attrs) do
    with {:ok, activity} <- insert(creator, context, attrs) do
      {:ok, %Activity{activity | context: context, creator: creator}}
    end
  end

  defp insert(creator, context, attrs) do
    Repo.insert(Activity.create_changeset(creator, context, attrs))
  end

  @doc """
  Update an already existing activity with the given attributes.
  """
  @spec update(Activity.t(), map) :: {:ok, Activity.t()} | {:error, Changeset.t()}
  def update(%Activity{} = activity, %{} = attrs),
    do: Repo.update(Activity.update_changeset(activity, attrs))

  @spec soft_delete(Activity.t()) :: {:ok, Activity.t()} | {:error, Changeset.t()}
  def soft_delete(%Activity{} = activity), do: Common.soft_delete(activity)
end
