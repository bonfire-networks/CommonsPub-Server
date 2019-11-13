# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
# defmodule MoodleNet.Collections do
#   alias MoodleNet.{Common, Meta, Repo}
#   alias MoodleNet.Actors.Actor
#   alias MoodleNet.Common.Query
#   alias MoodleNet.Collections.Collection
#   alias MoodleNet.Communities.Community
#   alias Ecto.Association.NotLoaded
#   import Ecto.Query

#   def count_for_list(), do: Repo.one(count_for_list_q())

#   def list(), do: Repo.all(list_q())

#   defp list_q() do
#     Collection
#     |> Query.only_public()
#     |> Query.only_undeleted()
#     |> Query.order_by_recently_updated()
#     |> only_from_undeleted_communities()
#   end

#   defp only_from_undeleted_communities(query) do
#     from q in query,
#       join: c in assoc(q, :community),
#       join: a in Actor, on: c.id == a.alias_id,
#       where: is_nil(c.deleted_at),
#       where: is_nil(a.deleted_at)
#   end

#   defp count_for_list_q() do
#     Collection
#     |> Query.only_public()
#     |> Query.only_undeleted()
#     |> only_from_undeleted_communities()
#     |> Query.count()
#   end

#   def count_for_list_in_community(%Actor{id: id}) do
#     Repo.one(Query.count(list_in_community_q(id)))
#   end

#   def list_in_community(%Actor{id: id}) do
#     Repo.all(list_in_community_q(id))
#   end

#   defp list_in_community_q(id) do
#     from c in Collection,
#       join: c2 in Community, on: c.community_id == c2.id,
#       join: a in Actor, on: a.alias_id == c2.id,
#       where: a.id == ^id,
#       where: not is_nil(c.published_at),
#       where: is_nil(c.deleted_at),
#       where: is_nil(c2.deleted_at),
#       where: is_nil(a.deleted_at)
#   end

#   defp count_for_list_in_community_q(id), do: Query.count(list_in_community_q(id))

#   def fetch(id), do: Repo.single(fetch_q(id))

#   defp fetch_q(id) do
#     from c in Collection,
#       join: c2 in Community, on: c.community_id == c2.id,
#       join: a in Actor, on: a.alias_id == c2.id,
#       where: c.id == ^id,
#       where: not is_nil(c.published_at),
#       where: is_nil(c.deleted_at),
#       where: is_nil(c2.deleted_at),
#       where: is_nil(a.deleted_at)
#   end


#   @spec create(Community.t(), Actor.t(), attrs :: map) :: \
#           {:ok, %Collection{}} | {:error, Changeset.t()}
#   def create(community, creator, attrs) when is_map(attrs) do
#     Repo.transact_with(fn ->
#       Meta.point_to!(Collection)
#       |> Collection.create_changeset(community, creator, attrs)
#       |> Repo.insert()
#     end)
#   end

#   @spec update(%Collection{}, attrs :: map) :: {:ok, %Collection{}} | {:error, Changeset.t()}
#   def update(%Collection{} = collection, attrs) do
#     Repo.transact_with(fn ->
#       collection
#       |> Collection.update_changeset(attrs)
#       |> Repo.update()
#     end)
#   end

#   def soft_delete(%Collection{}=collection), do: Common.soft_delete(collection)

#   def fetch_creator(%Collection{creator_id: id, creator: %NotLoaded{}}), do: Actors.fetch(id)
#   def fetch_creator(%Collection{creator: creator}), do: {:ok, creator}
# end
