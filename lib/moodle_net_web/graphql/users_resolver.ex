# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.UsersResolver do
  @moduledoc """
  Performs the GraphQL User queries.
  """
  # import MoodleNetWeb.GraphQL.MoodleNetSchema
  import MoodleNet.GraphQL.Schema
  require ActivityPub.Guards, as: APG
  alias Absinthe.Resolution
  alias MoodleNetWeb.GraphQL
  alias MoodleNetWeb.GraphQL.Errors
  alias MoodleNet.{Accounts, Actors, GraphQL, OAuth, Repo, Users}
  alias MoodleNet.Common.NotPermittedError
  alias MoodleNet.OAuth.Token

  def check_username_available(%{username: username}, _info),
    do: {:ok, Actors.is_username_available?(username)}

  def me(_, info) do
    with {:ok, current_user} <- GraphQL.current_user(info),
         {:ok, actor} <- Users.fetch_actor(current_user) do
      # FIXME
      actor = GraphQL.response(actor, info, ~w(user)a)
      {:ok, %{email: current_user.email, user: actor}}
    end
    |> GraphQL.response(info)
  end

  def user(%{id: id}, info) do
    with {:ok, current_user} <- GraphQL.current_user(info) do
      Actors.fetch(id)
    end
    |> GraphQL.response(info)
  end

  def create(%{user: attrs}, info) do
    with :ok <- GraphQL.guest_only(info),
         {:ok, user} <- Users.register(attrs) do
      user = Map.put(GraphQL.response(user.actor, info), :email, user.email)
      {:ok, user}
    else
      err -> GraphQL.response(err, info)
    end
  end

  def update_profile(%{profile: attrs}, info) do
    with {:ok, user} <- GraphQL.current_user(info),
         {:ok, user} <- Users.update(user, attrs),
         {:ok, actor} <- Users.fetch_actor(user) do
      actor = GraphQL.response(actor, info, ~w(user)a)
      {:ok, %{email: user.email, user: actor}}
    end
    |> GraphQL.response(info)
  end

  def delete(_, info) do
    with {:ok, user} <- GraphQL.current_user(info),
         {:ok, _} <- Users.soft_delete(user) do
      {:ok, true}
    else
      err -> GraphQL.response(err, info)
    end
  end

  def create_session(%{email: email, password: password}, info) do
    with {:ok, user} <- Users.fetch_by_email(email),
         {:ok, actor} <- Users.fetch_actor(user),
         {:ok, token} <- OAuth.create_token(user, password) do
      actor = GraphQL.response(actor, info, ~w(user)a)
      me = %{email: user.email, user: actor}
      {:ok, %{token: token.id, me: me}}
    else
      # don't expose if email or password failed
      _ -> {:error, NotPermittedError.new()}
    end
    |> GraphQL.response(info)
  end

  def delete_session(_, info) do
    with {:ok, user} <- GraphQL.current_user(info),
         {:ok, token} <- OAuth.fetch_session_token(user),
         {:ok, token} <- OAuth.hard_delete(token) do
      {:ok, true}
    else
      err -> GraphQL.response(err, info)
    end
  end

  def reset_password_request(%{email: email}, info) do
    with {:ok, user} <- Users.fetch_by_email(email),
         {:ok, token} <- Users.request_password_reset(user) do
      {:ok, token.id}
    else
      err -> GraphQL.response(err, info)
    end
  end

  def reset_password(%{token: token, password: password}, info) do
    with {:ok, _} <- Users.claim_password_reset(token, password) do
      {:ok, true}
    else
      err -> GraphQL.response(err, info)
    end
  end

  def confirm_email(%{token: token}, info) do
    Repo.transact_with(fn ->
      with {:ok, user} <- Users.claim_email_confirm_token(token),
           {:ok, auth} <- OAuth.create_auth(user),
           {:ok, auth_token} <- OAuth.claim_token(auth) do
        {:ok, auth_token.id}
      else
        err -> GraphQL.response(err, info)
      end
    end)
  end

  def inbox(_params, _info) do
  end
end
