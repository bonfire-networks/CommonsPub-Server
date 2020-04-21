# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.AdminResolver do
  alias ActivityPub.Actor
  alias MoodleNet.GraphQL
  alias MoodleNet.Mail.{Email, MailService}
  alias MoodleNet.Access
  alias MoodleNet.Adapter

  def admin(_, _info), do: {:ok, %{}}

  def resolve_flag(%{flag_id: _id}, _info) do
    {:ok, nil}
  end

  def deactivate_user(%{id: id}, info) do
    with {:ok, _user} <- GraphQL.admin_or_not_permitted(info),
         {:ok, actor} <- Actor.get_cached_by_local_id(id),
         {:ok, actor} <- Actor.deactivate(actor),
         {:ok, user} <- MoodleNet.Users.one(id: id),
         {:ok, user} <- MoodleNet.Users.update_remote(user, %{is_disabled: true}) do
      {:ok, user}
    end
  end

  def send_invite(%{email: email}, info) do
    with {:ok, _user} <- GraphQL.admin_or_not_permitted(info),
         {:ok, _access} <- Access.find_or_add_register_email(email) do
      email
      |> Email.invite()
      |> MailService.deliver_now()

      {:ok, true}
    else
      {:error, message} -> {:error, message}
    end
  end
end
