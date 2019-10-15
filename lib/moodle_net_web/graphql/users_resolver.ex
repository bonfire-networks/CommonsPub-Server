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
  alias MoodleNetWeb.GraphQL.Errors
  alias MoodleNet.{Accounts, Actors, GraphQL, OAuth, Users}

  def check_username_available(%{username: username}, _info),
    do: {:ok, Actors.is_username_available?(username)}

  def me(_, info) do
    with {:ok, current_user} <- GraphQL.current_user(info),
         {:ok, actor} <- Users.fetch_actor(current_user) do
      actor = GraphQL.response(actor, info, ~w(user)a)
      me = GraphQL.response(%{email: current_user.email, user: actor}, info)
      {:ok, me}
    else
      other -> GraphQL.response(other, info)
    end
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
    # with {:ok, current_actor} <- current_actor(info),
    #      {:ok, current_actor} <- Accounts.update_user(current_actor, attrs) do
    #   user_fields = requested_fields(info, :user)
    #   current_actor = prepare(:me, current_actor, user_fields)
    #   {:ok, current_actor}
    # end
    # |> Errors.handle_error()
  end

  def delete(_, info) do
    
    # with {:ok, current_actor} <- current_actor(info) do
    #   Accounts.delete_user(current_actor)
    #   {:ok, true}
    # end
  end

  def create_session(%{email: email, password: password}, info) do
    # with {:ok, user} <- Accounts.authenticate_by_email_and_pass(email, password),
    #      {:ok, token} <- OAuth.create_token(user.id) do
    #   actor = load_actor(user)
    #   auth_payload = prepare(:auth_payload, token, actor, info)
    #   {:ok, auth_payload}
    # else
    #   _ ->
    #     Errors.invalid_credential_error()
    # end
  end

  def delete_session(_, info) do
    # with {:ok, _} <- current_user(info) do
    #   OAuth.revoke_token(info.context.auth_token)
    #   {:ok, true}
    # end
  end

  def reset_password_request(%{email: email}, _info) do
    # # Note: This can be done async, but then, the async tests will fail
    # Accounts.reset_password_request(email)
    # {:ok, true}
  end

  def reset_password(%{token: token, password: password}, _info) do
    # with {:ok, _} <- Accounts.reset_password(token, password) do
    #   {:ok, true}
    # end
    # |> Errors.handle_error()
  end

  def confirm_email(%{token: token}, info) do
    with {:ok, _} <- Users.claim_email_confirm_token(token) do
      {:ok, true}
    else
      err -> GrapGL.response(err, info)
    end
  end
end
