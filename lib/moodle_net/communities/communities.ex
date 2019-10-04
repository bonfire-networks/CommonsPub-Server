# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Communities do
  alias Ecto.Changeset
  alias MoodleNet.Actors.Actor
  alias MoodleNet.{Meta, Repo}
  alias MoodleNet.Communities.Community
  alias MoodleNet.Localisation.Language

  @spec create(Actor.t(), Language.t(), attrs :: map) :: {:ok, Community.t()} | {:error, Changeset.t()}
  def create(%Actor{} = creator, %Language{} = language, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      Meta.point_to!(Community)
      |> Community.create_changeset(creator, language, attrs)
      |> Repo.insert()
    end)
  end

  @spec update(%Community{}, attrs :: map) :: {:ok, Community.t()} | {:error, Changeset.t()}
  def update(%Community{} = community, attrs) when is_map(attrs) do
    Repo.transact_with(fn ->
      community
      |> Community.update_changeset(attrs)
      |> Repo.update()
    end)
  end

  def join(community, member) do
  end

  def leave(community, member) do
  end
end
