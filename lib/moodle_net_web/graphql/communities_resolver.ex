# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CommunitiesResolver do
  @moduledoc """
  Performs the GraphQL Community queries.
  """
  import MoodleNet.GraphQL.Schema
  alias Absinthe.Resolution
  alias MoodleNetWeb.GraphQL
  alias MoodleNetWeb.GraphQL.Errors
  alias MoodleNet.{Accounts, Actors, Communities, GraphQL, Repo, Users}
  alias MoodleNet.Common.NotPermittedError
  alias MoodleNet.OAuth.Token

  alias MoodleNetWeb.GraphQL.Errors

  def list(args, info) do
    # to_page(:community, args, info)
  end

  def fetch(%{community_id: id}, info) do
    with {:ok, actor} <- Actors.fetch_by_alias(id) do
      {:ok, %{actor | id: id}}
    end
    |> GraphQL.response(info)
  end

  def create(%{community: attrs}, info) do
    with {:ok, user} <- GraphQL.current_user(info),
         {:ok, actor} <- Users.fetch_actor(user) do
      Communities.create(user, actor, attrs)
    end
    |> GraphQL.response(info)
  end

  def update(%{community: changes, community_id: id}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- GraphQL.current_user(info),
           {:ok, actor} <- Users.fetch_actor(user),
           {:ok, community} <- Communities.fetch(id) do
        if community.creator_id == actor.id do
          Communities.update(community, changes)
        else
          GraphQL.not_permitted()
	end
      end
    end)
    |> GraphQL.response(info)
  end

  def delete(%{community_id: id}, info) do
    Repo.transact_with fn ->
      with {:ok, user} <- GraphQL.current_user(info),
           {:ok, actor} <- Users.fetch_actor(user),
           {:ok, community} <- Communities.fetch(id) do
        if community.creator_id == actor.id do
          case Communities.soft_delete(community) do
            {:ok, _} -> {:ok, true}
            error -> GraphQL.response(error, info)
          end
        else
          GraphQL.response(GraphQL.not_permitted(), info)
        end
      else
        other -> GraphQL.response(other, info)
      end
    end
  end

  def follow(%{community_id: id}, info) do
    with {:ok, user} <- GraphQL.current_user(info),
         {:ok, actor} <- Users.fetch_actor(user),
         {:ok, community} <- Communities.fetch(id) do
      Common.follow(actor, community)
    end
    |> GraphQL.response(info)
  end

  def unfollow(%{community_id: id}, info) do
    with {:ok, user} <- GraphQL.current_user(info),
         {:ok, actor} <- Users.fetch_actor(user),
         {:ok, community} <- Communities.fetch(id),
         {:ok, follow} <- Common.find_follow(actor, community) do
      Common.unfollow(follow)
    end
    |> GraphQL.response(info)
  end

  def creator(community, _, _) do
  end
  def collections(community, _, _) do
  end
  def threads(community, _, _) do
  end
  def inbox(community, _, _) do
  end
  def outbox(community, _, _) do
  end

end
