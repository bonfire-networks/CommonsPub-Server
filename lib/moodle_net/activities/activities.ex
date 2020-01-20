# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Activities do
  import Ecto.Query

  alias MoodleNet.{Common, Meta, Repo, Users}
  alias MoodleNet.Activities.{Activity, Queries}
  alias MoodleNet.Users.User
  alias MoodleNet.Common.{NotFoundError, Query}
  alias Ecto.Association.NotLoaded

  def one(filters \\ []), do: Repo.single(Queries.query(Activity, filters))

  def many(filters \\ []), do: Repo.all(Queries.query(Activity, filters))

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
