# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNet.GraphQL.FieldsFlow do
  @enforce_keys [:queries, :query, :group_fn]
  defstruct [
    :queries,
    :query,
    :group_fn,
    map_fn: nil,
    filters: [],
  ]

  alias MoodleNet.Repo
  alias MoodleNet.GraphQL.{Fields, FieldsFlow}

  @type t :: %FieldsFlow{
    queries: atom,
    query: atom,
    group_fn: (term -> term),
    map_fn: (term -> term) | nil,
    filters: list,
  }

  def run(
    %FieldsFlow{
      queries: queries,
      query: query,
      group_fn: group_fn,
      map_fn: map_fn,
      filters: filters,
    }
  ) do
    apply(queries, :query, [query, filters])
    |> Repo.all()
    |> Fields.new(group_fn, map_fn)
  end

end
