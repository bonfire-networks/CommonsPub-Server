# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Access.RegisterEmailDomainAccesses do

  alias MoodleNet.Repo
  alias MoodleNet.Access.{RegisterEmailDomainAccess, RegisterEmailDomainAccessesQueries}
  alias MoodleNet.Batching.EdgesPage

  def one(filters) do
    RegisterEmailDomainAccessesQueries.query(RegisterEmailDomainAccess, filters)
    |> Repo.single()
  end

  def many(filters \\ []) do
    query = RegisterEmailDomainAccessesQueries.query(RegisterEmailDomainAccess, filters)
    {:ok, Repo.all(query)}
  end

  def edges_page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  when is_function(cursor_fn, 1) do
    {data_q, count_q} = RegisterEmailDomainAccessesQueries.queries(RegisterEmailDomainAccess, base_filters, data_filters, count_filters)
    with {:ok, [data, count]} <- Repo.transact_many(all: data_q, count: count_q) do
      {:ok, EdgesPage.new(data, count, cursor_fn, page_opts)}
    end
  end

  def create(email) do
    Repo.insert(RegisterEmailDomainAccess.create_changeset(%{email: email}))
  end
  
end
