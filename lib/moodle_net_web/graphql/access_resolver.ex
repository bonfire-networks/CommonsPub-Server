# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.AccessResolver do
  
  alias MoodleNet.{Access, GraphQL}
  alias MoodleNet.GraphQL.{ResolveRootPage, FetchPage}

  def register_email_accesses(page_opts, info) do
    with {:ok, _user} <- GraphQL.admin_or_not_permitted(info) do
      ResolveRootPage.run(
        %ResolveRootPage{
          module: __MODULE__,
          fetcher: :fetch_register_email_accesses,
          page_opts: page_opts,
          paging_opts: %{default_limit: 10, max_limit: 50},
          info: info,
        }
      )
    end
  end

  def fetch_register_email_accesses(page_opts, _info) do
    FetchPage.run(
      %FetchPage{
        queries: Access.RegisterEmailAccessesQueries,
        query: Access.RegisterEmailAccess,
        page_opts: page_opts,
      }
    )
  end

  def register_email_domain_accesses(page_opts, info) do
    with {:ok, _user} <- GraphQL.admin_or_not_permitted(info) do
      ResolveRootPage.run(
        %ResolveRootPage{
          module: __MODULE__,
          fetcher: :fetch_register_email_domain_accesses,
          page_opts: page_opts,
          paging_opts: %{default_limit: 10, max_limit: 50},
          info: info,
        }
      )
    end
  end

  def fetch_register_email_domain_accesses(page_opts, _info) do
    FetchPage.run(
      %FetchPage{
        queries: Access.RegisterEmailDomainAccessesQueries,
        query: Access.RegisterEmailDomainAccess,
        page_opts: page_opts,
      }
    )
  end

  ### mutations

  def create_register_email_access(%{email: email}, info) do
    with {:ok, _user} <- GraphQL.admin_or_not_permitted(info) do
      Access.RegisterEmailAccesses.create(email)
    end
  end
  def create_register_email_domain_access(%{domain: domain}, info) do
    with {:ok, _user} <- GraphQL.admin_or_not_permitted(info) do
      Access.RegisterEmailDomainAccesses.create(domain)
    end
  end

end
