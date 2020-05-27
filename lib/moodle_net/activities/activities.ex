# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Activities do

  alias MoodleNet.{Activities, Common, Repo}
  alias MoodleNet.Activities.{Activity, Queries}
  alias MoodleNet.Users.User

  def one(filters \\ []), do: Repo.single(Queries.query(Activity, filters))

  def many(filters \\ []), do: {:ok, Repo.all(Queries.query(Activity, filters))}

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
  @spec update(User.t(), Activity.t(), map) :: {:ok, Activity.t()} | {:error, Changeset.t()}
  def update(%User{}, %Activity{} = activity, %{} = attrs),
    do: Repo.update(Activity.update_changeset(activity, attrs))

  def update_by(%User{}=user, filters, updates) do
    Repo.update_all(Queries.query(Activity, filters), set: updates)
  end

  @spec soft_delete(User.t(), Activity.t()) :: {:ok, Activity.t()} | {:error, Changeset.t()}
  def soft_delete(%User{}, %Activity{} = activity), do: Common.soft_delete(activity)

  def soft_delete_by(%User{}=user, filters) do
    update_by(user, [{:deleted, false} | filters], deleted_at: DateTime.utc_now())
    :ok
  end

end
