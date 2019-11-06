# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Collections do
  alias MoodleNet.{Repo, Meta}
  alias MoodleNet.Collections.Collection

  @spec create(Community.t(), Actor.t(), attrs :: map) :: \
          {:ok, %Collection{}} | {:error, Changeset.t()}
  def create(community, creator, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      Meta.point_to!(Collection)
      |> Collection.create_changeset(community, creator, attrs)
      |> Repo.insert()
    end)
  end

  @spec update(%Collection{}, attrs :: map) :: {:ok, %Collection{}} | {:error, Changeset.t()}
  def update(%Collection{} = collection, attrs) do
    Repo.transact_with(fn ->
      collection
      |> Collection.update_changeset(attrs)
      |> Repo.update()
    end)
  end
end
