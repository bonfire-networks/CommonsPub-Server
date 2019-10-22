# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Resources do
  alias Ecto.Changeset
  alias MoodleNet.{Common, Repo, Meta}
  alias MoodleNet.Common.{Revision, NotFoundError}
  alias MoodleNet.Resources.{Resource, ResourceRevision, ResourceLatestRevision}

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
end
