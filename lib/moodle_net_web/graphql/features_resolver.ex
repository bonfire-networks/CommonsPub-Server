# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.FeaturesResolver do
  @moduledoc """
  Performs the GraphQL Community queries.
  """
  alias MoodleNet.{Features, GraphQL}
  alias MoodleNet.Meta.Pointers

  def feature(%{feature_id: id}, _info), do: Features.one(id: id)

  def features(_args, _info) do
    Features.nodes_page(
      &(&1.id),
      [],
      [join: :context, order: :timeline_desc, prefetch: :context])
  end

  def create_feature(%{context_id: id}, info) do
    with {:ok, user} <- GraphQL.admin_or_not_permitted(info),
         {:ok, context} <- Pointers.one(id: id) do
      Features.create(user, context, %{is_local: true})
    end
  end

end
