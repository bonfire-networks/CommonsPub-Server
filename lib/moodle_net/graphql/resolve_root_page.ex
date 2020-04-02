# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.GraphQL.ResolveRootPage do
  @moduledoc """
  Encapsulates the flow of resolving a page in the absence of parents.
  """

  @enforce_keys [:module, :fetcher, :page_opts, :info]
  defstruct [
    :module, :fetcher, :page_opts, :info,
    cursor_validators: [&Ecto.ULID.cast/1],
    paging_opts: %{default_limit: 10},
  ]

  alias MoodleNet.GraphQL.ResolveRootPage
  alias MoodleNet.GraphQL

  def run(
    %ResolveRootPage{
      module: module,
      fetcher: fetcher,
      page_opts: page_opts,
      paging_opts: opts,
      info: info,
      cursor_validators: validators,
    }
  ) do
    with {:ok, page_opts} <- GraphQL.full_page_opts(page_opts, validators, opts) do
      info2 = Map.take(info, [:context])
      apply(module, fetcher, [page_opts, info2])
    end
  end

end
