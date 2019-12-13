# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CollectionsResolver do
  alias MoodleNet.{
    Collections,
    Common,
    Communities,
    GraphQL,
    Repo,
    Resources,
    Users,
  }
  alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Users.User

  def collections(_args, info) do
    Repo.transact_with(fn ->
      count = Collections.count_for_list()
      colls = Collections.list()
      {:ok, GraphQL.node_list(colls, count)}
    end)
  end

  def collection(%{collection_id: id}, info), do: Collections.fetch(id)

  def canonical_url(coll, _, _), do: {:ok, coll.actor.canonical_url}
  def preferred_username(coll, _, _), do: {:ok, Repo.preload(coll, :actor).actor.preferred_username}
  def is_local(coll, _, _), do: {:ok, is_nil(Repo.preload(coll, :actor).actor.peer_id)}
  def is_public(coll, _, _), do: {:ok, not is_nil(coll.published_at)}
  def is_disabled(coll, _, _), do: {:ok, not is_nil(coll.disabled_at)}
  def is_deleted(coll, _, _), do: {:ok, not is_nil(coll.deleted_at)}

  def create_collection(%{collection: attrs, community_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user(info),
           {:ok, community} <- Communities.fetch(id) do
        attrs = Map.merge(attrs, %{is_public: true})
        Collections.create(user, community, attrs)
      end
    end)
  end

  def update_collection(%{collection: changes, collection_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user(info),
           {:ok, collection} <- Collections.fetch(id) do
        collection = Repo.preload(collection, :community)
        cond do
          user.local_user.is_instance_admin ->
	    Collections.update(collection, changes)

          collection.creator_id == user.id ->
	    Collections.update(collection, changes)

          collection.community.creator_id == user.id ->
	    Collections.update(collection, changes)

          true -> GraphQL.not_permitted("update")
        end
      end
    end)
  end

  # def delete(%{collection_id: id}, info) do
  #   # Repo.transact_with(fn ->
  #   #   with {:ok, user} <- GraphQL.current_user(info),
  #   #        {:ok, actor} <- Users.fetch_actor(user),
  #   #        {:ok, collection} <- Collections.fetch(id) do
  #   #     collection = Repo.preload(collection, :community)
  #   # 	permitted =
  #   # 	  user.is_instance_admin or
  #   #       collection.creator_id == actor.id or
  #   #       collection.community.creator_id == actor.id
  #   # 	if permitted do
  #   # 	  with {:ok, _} <- Collections.soft_delete(collection), do: {:ok, true}
  #   # 	else
  #   # 	  GraphQL.not_permitted()
  #   #     end
  #   #   end
  #   # end)
  #   # |> GraphQL.response(info)
  #   {:ok, true}
  #   |> GraphQL.response(info)
  # end

  def resources(%Collection{}=coll, _, info) do
    Repo.transact_with(fn ->
      count = Resources.count_for_list_in_collection(coll)
      comms = Resources.list_in_collection(coll)
      {:ok, GraphQL.edge_list(comms, count, &(&1.id))}
    end)
  end

  def creator(%Collection{}=coll, _, info) do
    {:ok, Repo.preload(coll, [creator: :actor]).creator}
  end
  def community(%Collection{}=coll, _, info) do
    {:ok, Repo.preload(coll, [community: :actor]).community}
  end

  def last_activity(_, _, info) do
    {:ok, Fake.past_datetime()}
    |> GraphQL.response(info)
  end

  def outbox(collection,_,info) do
    # Repo.transact_with(fn ->
    #   activities =
    # 	Collections.outbox(collection)
    #     |> Enum.map(fn box -> %{cursor: box.id, node: box.activity} end)
    #   count = Collections.count_for_outbox(collection)
    #   page_info = Common.page_info(activities, &(&1.cursor))
    #   {:ok, %{page_info: page_info, total_count: count, edges: activities}}
    # end)
   {:ok, GraphQL.feed_list([],0)}
   end

end
