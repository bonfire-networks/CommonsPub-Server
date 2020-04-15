# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Access.RegisterEmailDomainAccesses do

  alias MoodleNet.Repo
  alias MoodleNet.Access.{RegisterEmailDomainAccess, RegisterEmailDomainAccessesQueries}
  alias MoodleNet.Common.Contexts

  def one(filters) do
    RegisterEmailDomainAccessesQueries.query(RegisterEmailDomainAccess, filters)
    |> Repo.single()
  end

  def many(filters \\ []) do
    query = RegisterEmailDomainAccessesQueries.query(RegisterEmailDomainAccess, filters)
    {:ok, Repo.all(query)}
  end

  @doc """
  Retrieves a Page of features according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def page(cursor_fn, page_opts, base_filters, data_filters, count_filters) do
    Contexts.page RegisterEmailDomainAccessesQueries, RegisterEmailDomainAccess,
      cursor_fn, page_opts, base_filters, data_filters, count_filters
  end

  @doc """
  Retrieves a Pages of features according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def pages(group_fn, cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ []) do
    Contexts.pages RegisterEmailDomainAccessQueries, RegisterEmailDomainAccess,
      cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters
  end

  def create(domain) do
    Repo.insert(RegisterEmailDomainAccess.create_changeset(%{domain: domain}))
  end

end
