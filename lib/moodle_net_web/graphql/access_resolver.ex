# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.AccessResolver do
  
  alias MoodleNet.GraphQL
  alias MoodleNet.Access.{RegisterEmailAccesses, RegisterEmailDomainAccesses}

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

  def create_register_email_access(%{email: email}, info) do
    with {:ok, user} <- GraphQL.admin_or_not_permitted(info) do
      RegisterEmailAccesses.create(email)
    end
  end
  def create_register_email_domain_access(%{domain: domain}, info) do
    with {:ok, user} <- GraphQL.admin_or_not_permitted(info) do
      RegisterEmailDomainAccesses.create(domain)
    end
  end

end
