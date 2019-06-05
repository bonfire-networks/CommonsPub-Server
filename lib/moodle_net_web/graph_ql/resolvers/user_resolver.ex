# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.UserResolver do
  import MoodleNetWeb.GraphQL.MoodleNetSchema
  require ActivityPub.Guards, as: APG
  alias MoodleNetWeb.GraphQL.Errors
  alias MoodleNet.{Accounts, OAuth, Repo}

  def me(_, info) do
    with {:ok, actor} <- current_actor(info) do
      user_fields = requested_fields(info, :user)
      me = prepare(:me, actor, user_fields)
      {:ok, me}
    end
  end

  def user(%{local_id: local_id}, info) do
    with {:ok, user} <- fetch(local_id, "Person") do
      fields = requested_fields(info)
      user = prepare(user, fields)
      {:ok, user}
    end
  end

  def create_user(%{user: attrs}, info) do
    attrs = attrs |> set_icon() |> set_location() |> set_website()

    with {:ok, %{actor: actor, user: user}} <- Accounts.register_user(attrs),
         {:ok, token} <- OAuth.create_token(user.id) do
      auth_payload = prepare(:auth_payload, token, actor, info)
      {:ok, auth_payload}
    end
    |> Errors.handle_error()
  end

  def update_profile(%{profile: attrs}, info) do
    with {:ok, current_actor} <- current_actor(info),
         {:ok, current_actor} <- Accounts.update_user(current_actor, attrs) do
      user_fields = requested_fields(info, :user)
      current_actor = prepare(:me, current_actor, user_fields)
      {:ok, current_actor}
    end
    |> Errors.handle_error()
  end

  def delete_user(_, info) do
    with {:ok, current_actor} <- current_actor(info) do
      Accounts.delete_user(current_actor)
      {:ok, true}
    end
  end

  def create_session(%{email: email, password: password}, info) do
    with {:ok, user} <- Accounts.authenticate_by_email_and_pass(email, password),
         {:ok, token} <- OAuth.create_token(user.id) do
      actor = load_actor(user)
      auth_payload = prepare(:auth_payload, token, actor, info)
      {:ok, auth_payload}
    else
      _ ->
        Errors.invalid_credential_error()
    end
  end

  def delete_session(_, info) do
    with {:ok, _} <- current_user(info) do
      OAuth.revoke_token(info.context.auth_token)
      {:ok, true}
    end
  end

  def check_username_available(%{username: username}, _info),
    do: {:ok, Accounts.is_username_available?(username)}

  def reset_password_request(%{email: email}, _info) do
    # Note: This can be done async, but then, the async tests will fail
    Accounts.reset_password_request(email)
    {:ok, true}
  end

  def reset_password(%{token: token, password: password}, _info) do
    with {:ok, _} <- Accounts.reset_password(token, password) do
      {:ok, true}
    end
    |> Errors.handle_error()
  end

  def confirm_email(%{token: token}, _info) do
    with {:ok, _} <- Accounts.confirm_email(token) do
      {:ok, true}
    end
    |> Errors.handle_error()
  end

  def prepare_user([e | _] = list, fields) when APG.has_type(e, "Person") do
    list
    |> preload_assoc_cond([:icon, :location, :attachment], fields)
    |> preload_aspect_cond([:actor_aspect], fields)
    |> Enum.map(&prepare(&1, fields))
  end

  def prepare_user(e, fields) when APG.has_type(e, "Person") do
    e
    |> preload_assoc_cond([:icon, :location, :attachment], fields)
    |> preload_aspect_cond([:actor_aspect], fields)
    |> prepare_common_fields()
  end
  
end
