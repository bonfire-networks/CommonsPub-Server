# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Resources do
  alias Ecto.Changeset
  alias MoodleNet.{Common, Repo, Meta}
  alias MoodleNet.Common.NotFoundError
  alias MoodleNet.Resources.Resource

  @spec fetch(binary()) :: {:ok, %Resource{}} | {:error, NotFoundError.t()}
  def fetch(id) do
    Repo.transact_with(fn ->
      with {:ok, resource} <- Repo.fetch(Resource, id) do
        {:ok, preload(resource)}
      end
    end)
  end

  @spec create(Collection.t(), User.t(), attrs :: map) ::
          {:ok, %Resource{}} | {:error, Changeset.t()}
  def create(collection, creator, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      Meta.point_to!(Resource)
      |> Resource.create_changeset(collection, creator, attrs)
      |> Repo.insert()
    end)
  end

  @spec update(%Resource{}, attrs :: map) :: {:ok, %Resource{}} | {:error, %Changeset{}}
  def update(%Resource{} = resource, attrs) when is_map(attrs) do
    Repo.update(Resource.update_changeset(resource, attrs))
  end

  def preload(%Resource{} = resource, opts \\ []) do
    Repo.preload(resource, [:creator], opts)
  end
end
