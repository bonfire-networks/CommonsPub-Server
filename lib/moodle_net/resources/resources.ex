# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Resources do
  alias Ecto.Changeset
  alias MoodleNet.{Common, Repo, Meta}
  alias MoodleNet.Common.{Revision, NotFoundError}
  alias MoodleNet.Resources.{Resource, ResourceRevision, ResourceLatestRevision, ResourceFlag}

  @spec fetch(binary()) :: {:ok, %Resource{}} | {:error, NotFoundError.t()}
  def fetch(id) do
    Repo.fetch(Resource, id)
  end

  @spec create(Collection.t(), Actor.t(), Language.t(), attrs :: map) :: {:ok, %Resource{}} | {:error, Changeset.t()}
  def create(collection, creator, language, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      pointer = Meta.point_to!(Resource)

      changeset = Resource.create_changeset(pointer, collection, creator, language, attrs)
      with {:ok, resource} <- Repo.insert(changeset),
           {:ok, revision} <- Revision.insert(ResourceRevision, resource, attrs) do
        latest_revision = ResourceLatestRevision.forge(revision)
        {:ok, %Resource{resource | latest_revision: latest_revision, current: revision}}
      end
    end)
  end

  @spec update(%Resource{}, attrs :: map) :: {:ok, %Resource{}} | {:error, %Changeset{}}
  def update(%Resource{} = resource, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      with {:ok, resource} <- Repo.update(Resource.update_changeset(resource, attrs)),
           {:ok, revision} <- Revision.insert(ResourceRevision, resource, attrs) do
        latest_revision = ResourceLatestRevision.forge(revision)
        {:ok, %Resource{resource | latest_revision: latest_revision, current: revision}}
      end
    end)
  end

  @doc """
  Likes a resource with a given reason
  {:ok, ResourceLike} | {:error, reason}
  """
  def like(actor, resource),
    do: Common.like(ResourceLike, :like_resource?, actor, resource)

  @doc """
  Undoes a previous like
  {:ok, ResourceLike} | {:error, term()}
  """
  def undo_like(actor, resource), do: Common.undo_like(ResourceLike, actor, resource)

  @doc """
  Lists all ResourceLike matching the provided optional filters.
  Filters:
    :open :: boolean
  """
  def all_likes(actor, filters \\ %{}),
    do: Common.likes(ResourceLike, :list_resource_likes?, actor, filters)

  @doc """
  Flags a resource with a given reason
  {:ok, ResourceFlag} | {:error, reason}
  """
  def flag(actor, resource, attrs = %{reason: _}),
    do: Common.flag(ResourceFlag, :flag_resource?, actor, resource, attrs)

  @doc """
  Undoes a previous flag
  {:ok, ResourceFlag} | {:error, term()}
  """
  def undo_flag(actor, resource), do: Common.undo_flag(ResourceFlag, actor, resource)

  @doc """
  Lists all ResourceFlag matching the provided optional filters.
  Filters:
    :open :: boolean
  """
  def all_flags(actor, filters \\ %{}),
    do: Common.flags(ResourceFlag, :list_resource_flags?, actor, filters)
end
