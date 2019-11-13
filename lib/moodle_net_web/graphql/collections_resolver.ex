# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CollectionsResolver do
  alias MoodleNet.{Collections, Common, Communities, GraphQL, Repo, Users}
  alias MoodleNet.Fake
  alias MoodleNet.Collection.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Users.User

  def collections(_args, info) do
    # Repo.transact_with(fn ->
    #   count = Collections.count_for_list()
    #   comms = Collections.list()
    #   page_info = Common.page_info(comms)
    #   {:ok, %{page_info: page_info, total_count: count, nodes: comms}}
    # end)
    {:ok, Fake.long_node_list(&Fake.collection/0)}
    |> GraphQL.response(info)
  end

  def collections(%Community{}=parent, _, info) do
    {:ok, Fake.long_edge_list(&Fake.collection/0)}
    |> GraphQL.response(info)
    # count = Fake.pos_integer()
    # comms = Fake.long_list(&Fake.collection/0)
    # {:ok, GraphQL.edge_list(comms, count)}
    # |> GraphQL.response(info)
  end

  def collection(%{collection_id: id}, info) do
    {:ok, Fake.collection()}
    |> GraphQL.response(info)
    # GraphQL.response(Collections.fetch(id), info)
  end

  def collection(_,_,info) do
    {:ok, Fake.collection()}
    |> GraphQL.response(info)
  end
  def create_collection(%{collection: attrs, community_id: community_id}, info) do
    # Repo.transact_with(fn ->
    #   with {:ok, user} <- GraphQL.current_user(info),
    #        {:ok, actor} <- Users.fetch_actor(user),
    #        {:ok, community} <- Communities.fetch(id) do
    # 	permitted =
    # 	  user.is_instance_admin or
    #       collection.creator_id == actor.id or
    # 	if permitted do
    #       Collections.create(community, actor, attrs)
    # 	else
    # 	  GraphQL.not_permitted()
    # 	end
    #   end
    # end)
    # |> GraphQL.response(info)
    {:ok, Fake.collection()}
    |> GraphQL.response(info)
  end

  def update_collection(%{collection: changes, collection_id: id}, info) do
    # with {:ok, actor} <- current_actor(info),
    #      {:ok, collection} <- fetch(id, "MoodleNet:Collection"),
    #      {:ok, collection} <- MoodleNet.update_collection(actor, collection, changes) do
    #   fields = requested_fields(info)
    #   {:ok, prepare(collection, fields)}
    # end
    # |> Errors.handle_error()
    {:ok, Fake.collection()}
    |> GraphQL.response(info)
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

  def last_activity(_, _, info) do
    {:ok, Fake.past_datetime()}
    |> GraphQL.response(info)
  end

  def outbox(_,_,info) do
    {:ok, Fake.long_edge_list(&Fake.activity/0)}
    |> GraphQL.response(info)
  end

end
