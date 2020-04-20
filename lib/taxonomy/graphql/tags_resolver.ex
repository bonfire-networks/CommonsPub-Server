# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Taxonomy.GraphQL.TagsResolver do
  @moduledoc "GraphQL tag and Country queries"
  alias MoodleNet.{GraphQL}
  alias Taxonomy.{Tags}

  def tags(_, info) do
    Tags.nodes_page(
      &(&1.id),
      [],
      []
      )
  end

  # def tag(%{tag_id: id}, info) do
  #   {:ok, Fake.tag()}
  #   |> GraphQL.response(info)
  # end

  # def search_tag(%{query: id}, info) do
  #   {:ok, Fake.long_node_list(&Fake.tag/0)}
  #   |> GraphQL.response(info)
  # end



end
