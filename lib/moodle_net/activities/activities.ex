# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Activities do
  import Ecto.Query

  alias MoodleNet.{Common, Meta, Repo, Users}
  alias MoodleNet.Activities.Activity
  alias MoodleNet.Users.User
  alias MoodleNet.Common.{NotFoundError, Query}
  alias Ecto.Association.NotLoaded

  @type context :: %{id: binary}

  @doc """
  Return a list of activities related to any context that participates in the
  meta abstraction.

  Will ignore unpublished or deleted activities.
  """
  @spec list_by_context(context()) :: [Activity.t()]
  def list_by_context(%{id: id}) do
    query =
      from(a in Activity,
        where: a.context_id == ^id
      )
      |> only_public_q()

    Repo.all(query)
  end

  @doc """
  Return a list of activities related to a user.

  Will ignore unpublished or deleted activities.
  """
  @spec list_by_user(User.t()) :: [Activity.t()]
  def list_by_user(%User{id: id}) do
    query =
      from(a in Activity,
        where: a.creator_id == ^id
      )
      |> only_public_q()

    Repo.all(query)
  end

  @doc """
  Fetch an activity by its ID.

  Will ignore unpublished or deleted activities.
  """
  @spec fetch(binary()) :: {:ok, Activity.t()} | {:error, NotFoundError.t()}
  def fetch(id) do
    query =
      from(a in Activity,
        where: a.id == ^id
      )
      |> only_public_q()

    Repo.single(query)
  end

  defp only_public_q(query) do
    query
    |> Query.only_public()
    |> Query.only_undeleted()
  end

  @doc """
  Fetch an activity by its ID, regardless of its published or deleted status.
  """
  @spec fetch_private(binary()) :: {:ok, Activity.t()} | {:error, NotFoundError.t()}
  def fetch_private(id), do: Repo.fetch(Activity, id)

  @doc """
  Fetch the user related to an activity.

  Will ignore users that are deleted.
  """
  @spec fetch_user(Activity.t()) :: {:ok, User.t()} | {:error, NotFoundError.t()}
  def fetch_user(%Activity{creator_id: id, creator: %NotLoaded{}}), do: Users.fetch(id)
  def fetch_user(%Activity{creator: user}), do: {:ok, user}

  @doc """
  Fetch the context related to an activity and resolve it to its original type.
  """
  @spec fetch_context(Activity.t()) :: {:ok, context()} | {:error, NotFoundError.t()}
  def fetch_context(%Activity{context_id: id, context: %NotLoaded{}}) do
    with {:ok, context} <- Meta.find(id) do
      Meta.follow(context)
    end
  end

  def fetch_context(%Activity{context: context}), do: {:ok, context}

  @doc """
  Create a new activity related to any context that participates in the meta
  abstraction.
  """
  @spec create(context(), User.t(), map) :: {:ok, Activity.t()} | {:error, Changeset.t()}
  def create(%{id: _} = context, %User{} = user, %{} = attrs) do
    Repo.transact_with(fn ->
      with {:ok, activity} <- insert_activity(context, user, attrs) do
        {:ok, %Activity{activity | context: context, creator: user}}
      end
    end)
  end

  defp insert_activity(context, user, attrs) do
    context = Meta.find!(context.id)

    Activity.create_changeset(context, user, attrs)
    |> Repo.insert()
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
