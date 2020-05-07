# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Activities do

  alias MoodleNet.{Activities, Common, Repo}
  alias MoodleNet.Activities.{Activity, Queries}
  alias MoodleNet.Common.Contexts
  alias MoodleNet.Users.User

  def one(filters \\ []), do: Repo.single(Queries.query(Activity, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Activity, filters))}

  @doc """
  Retrieves a Page of feed activities according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def page(cursor_fn, page_opts, base_filters, data_filters, count_filters) do
    Contexts.page Queries, Activity,
      cursor_fn, page_opts, base_filters, data_filters, count_filters
  end

  @doc """
  Retrieves a Page of feed activities according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def pages(cursor_fn, group_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def pages(cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters) do
    Contexts.pages Queries, Activity,
      cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters
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

  def update_by(filters, updates) do
    Queries.query(Activity)
    |> Queries.filter(filters)
    |> Repo.update_all(updates)
  end

  defp update_by_result({count, _}), do: {:ok, count}

  @spec soft_delete(Activity.t()) :: {:ok, Activity.t()} | {:error, Changeset.t()}
  def soft_delete(%Activity{} = activity), do: Common.soft_delete(activity)

end
