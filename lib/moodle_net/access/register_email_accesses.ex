# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.Access.RegisterEmailAccesses do

  alias MoodleNet.Repo
  alias MoodleNet.Access.{RegisterEmailAccess, RegisterEmailAccessesQueries}
  alias MoodleNet.Common.Contexts

  def one(filters) do
    Repo.single(RegisterEmailAccessesQueries.query(RegisterEmailAccess, filters))
  end

  def many(filters \\ []) do
    {:ok, Repo.all(RegisterEmailAccessesQueries.query(RegisterEmailAccess, filters))}
  end

  @doc """
  Retrieves a Page of features according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def page(cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ [])
  def page(cursor_fn, page_opts, base_filters, data_filters, count_filters) do
    Contexts.page RegisterEmailAccessesQueries, RegisterEmailAccess,
      cursor_fn, page_opts, base_filters, data_filters, count_filters
  end

  @doc """
  Retrieves a Pages of features according to various filters

  Used by:
  * GraphQL resolver bulk resolution
  """
  def pages(group_fn, cursor_fn, page_opts, base_filters \\ [], data_filters \\ [], count_filters \\ []) do
    Contexts.pages RegisterEmailAccessQueries, RegisterEmailAccess,
      cursor_fn, group_fn, page_opts, base_filters, data_filters, count_filters
  end

  def create(email) do
    Repo.insert(RegisterEmailAccess.create_changeset(%{email: email}))
  end

end
