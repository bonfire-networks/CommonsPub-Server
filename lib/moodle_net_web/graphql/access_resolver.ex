# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.AccessResolver do
  
  alias MoodleNet.GraphQL
  alias MoodleNet.Access.{RegisterEmailAccesses, RegisterEmailDomainAccesses}
  alias MoodleNet.GraphQL.{ResolveRootPage, FetchPage}
  alias MoodleNet.Users.User

  def register_email_accesses(_, info) do
    with {:ok, _user} <- GraphQL.admin_or_not_permitted(info) do
      RegisterEmailAccesses.nodes_page(&(&1.id))
    end
  end

  def register_email_domain_accesses(_, info) do
    with {:ok, _user} <- GraphQL.admin_or_not_permitted(info) do
      RegisterEmailDomainAccesses.nodes_page(&(&1.id))
    end
  end

  def fetch_register_email_domain_accesses(page_opts, _info) do
    FetchPage.run(
      %FetchPage{
        queries: Access.RegisterEmailDomainAccessesQueries,
        query: RegisterEmailDomainAccess,
        page_opts: page_opts,
      }
    )
  end

  ### mutations

  def create_register_email_access(%{email: email}, info) do
    with {:ok, _user} <- GraphQL.admin_or_not_permitted(info) do
      RegisterEmailAccesses.create(email)
    end
  end
  def create_register_email_domain_access(%{domain: domain}, info) do
    with {:ok, _user} <- GraphQL.admin_or_not_permitted(info) do
      RegisterEmailDomainAccesses.create(domain)
    end
  end

end
