# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.UsersResolver do
  @moduledoc """
  Performs the GraphQL User queries.
  """
  alias Absinthe.Resolution
  alias MoodleNetWeb.GraphQL
  alias MoodleNetWeb.GraphQL.Errors
  alias MoodleNet.{Accounts, Actors, Fake, GraphQL, OAuth, Repo, Users}
  alias MoodleNet.Common.{
    AlreadyFlaggedError,
    AlreadyFollowingError,
    NotFlaggableError,
    NotFoundError,
    NotPermittedError,
  }
  alias MoodleNet.Users.Me

  def username_available(%{username: username}, _info) do
    {:ok, Actors.is_username_available?(username)}
  end
  def me(_, info) do
    with {:ok, current_user} <- GraphQL.current_user(info) do
      {:ok, Me.new(current_user)}
    end
  end

  def user(%{user_id: id}, info) do
    {:ok, Fake.user()}
    |> GraphQL.response(info)
    # GraphQL.response(Users.fetch(id), info)
  end
  def user(_, _, info) do
    {:ok, Fake.user()}
    |> GraphQL.response(info)
    # GraphQL.response(Users.fetch(id), info)
  end

  # def user(%Activity{}=activity, _, info)
  # def user(%Like{}=like, _, info)
  # def user(%Flag{}=flag, _, info)
  # def user(%Block{}=flag, _, info)
  # def user(%Follow{}=flag, _, info)
  # def user(%Tagging{}=tagging, _, info)

  def create_user(%{user: attrs}, info) do
    # with :ok <- GraphQL.guest_only(info),
    #      {:ok, user} <- Users.register(attrs) do
    #   {:ok, Me.new(user)}
    # end
    {:ok, Fake.me()}
    |> GraphQL.response(info)
  end

  def update_profile(%{profile: attrs}, info) do
    # with {:ok, user} <- GraphQL.current_user(info),
    #      {:ok, user} <- Users.update(user, attrs) do
    #   {:ok, Me.new(user)}
    # end
    {:ok, Fake.me()}
    |> GraphQL.response(info)
  end

  def delete(%{i_am_sure: true}, info) do
    # with {:ok, user} <- GraphQL.current_user(info),
    #      {:ok, _} <- Users.delete(user) do
    #   {:ok, true}
    # end
    {:ok, true}
    |> GraphQL.response(info)
  end

  def create_session(%{email: email, password: password}, info) do
    # with {:ok, user} <- Users.fetch_by_email(email),
    #      {:ok, token} <- OAuth.create_token(user, password) do
    #   {:ok, %{token: token.id, me: Me.new(user)}}
    # else
    #   _ -> GraphQL.not_permitted()
# end
    {:ok, Fake.auth_payload()}
    |> GraphQL.response(info)
  end

  def delete_session(_, info) do
    # with {:ok, user} <- GraphQL.current_user(info),
    #      {:ok, token} <- OAuth.fetch_session_token(user),
    #      {:ok, token} <- OAuth.hard_delete(token) do
    #   {:ok, true}
    # end
    {:ok, true}
    |> GraphQL.response(info)
  end

  def reset_password_request(%{email: email}, info) do
    # with :ok <- GraphQL.guest_only(info),
    # 	 {:ok, user} <- Users.fetch_by_email(email),
    #      {:ok, token} <- Users.request_password_reset(user) do
    #   {:ok, true}
    # end
    {:ok, true}
    |> GraphQL.response(info)
  end

  def reset_password(%{token: token, password: password}, info) do
    # with :ok <- GraphQL.guest_only(info),
    # 	 {:ok, _} <- Users.claim_password_reset(token, password) do
    #   {:ok, true}
    # end
    {:ok, Fake.auth_payload()}
    |> GraphQL.response(info)
  end

  def confirm_email(%{token: token}, info) do
    # Repo.transact_with(fn ->
    #   with {:ok, user} <- Users.claim_email_confirm_token(token),
    #        {:ok, auth} <- OAuth.create_auth(user),
    #        {:ok, token} <- OAuth.claim_token(auth) do
    #     {:ok, %{token: token.id, me: Me.new(user)}}
    #   end
    # end)
    {:ok, Fake.auth_payload()}
    |> GraphQL.response(info)
  end

  def inbox(user, params, info) do
    # with {:ok, current_user} <- GraphQL.current_user(info) do
    #   if user.id == current_user.id do
    #     with {:ok, activities, count} <- Users.inbox(current_user) do
    #       {:ok, GraphQL.edge_list(activities, count)
    #     end
    #   else
    # 	GraphQL.not_permitted()
    #   end
    # end
    activities = Fake.long_list(&Fake.activity/0)
    count = Fake.pos_integer()
    {:ok, GraphQL.edge_list(activities, count)}
    |> GraphQL.response(info)    
  end

  def outbox(user, params, info) do
    # with {:ok, activities, count} <- Users.outbox(user) do
    #   {:ok, GraphQL.edge_list(activities, count)
    # end
    {:ok, Fake.long_edge_list(&Fake.activity/0)}
    |> GraphQL.response(info)    
  end

  def followed_communities(_,_,info) do
    {:ok, Fake.long_edge_list(&Fake.community_follow/0)}
    |> GraphQL.response(info)    
  end
  def followed_collections(_,_,info) do
    {:ok, Fake.long_edge_list(&Fake.collection_follow/0)}
    |> GraphQL.response(info)    
  end
  def followed_users(_,_,info) do
    {:ok, Fake.long_edge_list(&Fake.user_follow/0)}
    |> GraphQL.response(info)    
  end

  def creator(_,_,info) do
    {:ok, Fake.user()}
    |> GraphQL.response(info)
  end

  def last_activity(_,_,info) do
    {:ok, Fake.past_datetime()}
    |> GraphQL.response(info)
  end
    
end
