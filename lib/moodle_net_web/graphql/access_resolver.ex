# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.AccessResolver do
  alias MoodleNet.GraphQL
  alias MoodleNet.Access.{RegisterEmailAccesses, RegisterEmailDomainAccesses}

  def register_email_accesses(args, info) do
    with {:ok, _user} <- GraphQL.admin_or_not_permitted(info) do
      RegisterEmailAccesses.page(
        & &1.id,
        args,
        []
      )
    else
      _ -> {:ok, GraphQL.empty_page()}
    end
  end

  def register_email_domain_accesses(args, info) do
    with {:ok, _user} <- GraphQL.admin_or_not_permitted(info) do
      RegisterEmailDomainAccesses.page(
        & &1.id,
        args,
        []
      )
    else
      _ -> {:ok, GraphQL.empty_page()}
    end
  end

  def create_register_email_access(%{email: email}, info) do
    with {:ok, _user} <- GraphQL.admin_or_not_permitted(info),
         {:ok, access} <- RegisterEmailAccesses.create(email) do
      {:ok, access}
    else
      {:error, %MoodleNet.Access.NotPermittedError{} = message} ->
        {:error, message}

      {:error, _} ->
        {:error, "Email already whitelisted"}
    end
  end

  def create_register_email_domain_access(%{domain: domain}, info) do
    with {:ok, _user} <- GraphQL.admin_or_not_permitted(info),
         {:ok, access} <- RegisterEmailDomainAccesses.create(domain) do
      {:ok, access}
    else
      {:error, %MoodleNet.Access.NotPermittedError{} = message} ->
        {:error, message}

      {:error, _} ->
        {:error, "Domain already whitelisted"}
    end
  end

  def delete_register_email_access(%{id: id}, info) do
    with {:ok, _user} <- GraphQL.admin_or_not_permitted(info),
         {:ok, access} <- RegisterEmailAccesses.one(id: id) do
      RegisterEmailAccesses.hard_delete(access)
    end
  end

  def delete_register_email_domain_access(%{id: id}, info) do
    with {:ok, _user} <- GraphQL.admin_or_not_permitted(info),
         {:ok, access} <- RegisterEmailDomainAccesses.one(id: id) do
      RegisterEmailDomainAccesses.hard_delete(access)
    end
  end
end
