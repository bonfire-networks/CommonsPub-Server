# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.AccessResolver do

  alias MoodleNet.{Access, GraphQL}
  alias MoodleNet.GraphQL.{ResolveRootPage, FetchPage}
  alias MoodleNet.Users.User

  def register_email_accesses(page_opts, info) do
    with {:ok, %User{}} <- GraphQL.admin_or_empty_page(info) do
      ResolveRootPage.run(
        %ResolveRootPage{
          module: __MODULE__,
          fetcher: :fetch_register_email_accesses,
          page_opts: page_opts,
          info: info,
        }
      )
    end
  end

  def fetch_register_email_accesses(page_opts, _info) do
    FetchPage.run(
      %FetchPage{
        queries: Access.RegisterEmailAccessQueries,
        query: Access.RegisterEmailAccesses,
        page_opts: page_opts,
      }
    )
  end

  def register_email_domain_accesses(page_opts, info) do
    with {:ok, %User{}} <- GraphQL.admin_or_empty_page(info) do
      ResolveRootPage.run(
        %ResolveRootPage{
          module: __MODULE__,
          fetcher: :fetch_register_email_domain_accesses,
          page_opts: page_opts,
          info: info,
        }
      )
    end
  end

  def fetch_register_email_domain_accesses(page_opts, _info) do
    FetchPage.run(
      %FetchPage{
        queries: Access.RegisterEmailDomainAccessQueries,
        query: Access.RegisterEmailDomainAccesses,
        page_opts: page_opts,
      }
    )
  end

  ### mutations

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
