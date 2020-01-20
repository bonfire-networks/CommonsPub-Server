# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.FeaturesResolver do
  @moduledoc """
  Performs the GraphQL Community queries.
  """
  import Ecto.Query
  alias Absinthe.Relay
  alias MoodleNet.{Features, GraphQL, Repo}
  alias MoodleNet.Meta.Pointers
  import Absinthe.Resolution.Helpers, only: [batch: 3]

  def feature(%{feature_id: id}, _info), do: Features.one(id: id)

  def features(_args, _info) do
    {:ok, Features.many(join: :context, order: :timeline_desc, prefetch: :context)}
  end

  def create_feature(%{context_id: id}, info) do
    with {:ok, user} <- GraphQL.admin_or_not_permitted(info),
         {:ok, context} <- Pointers.one(id: id),
         target_table = Pointers.table!(context) do
      if target_table.schema in get_valid_contexts() do
        Features.create(user, context, %{is_local: true})
      else
        {:error, GraphQL.not_permitted()}
      end
    end
  end

  def get_valid_contexts() do
    Application.fetch_env!(:moodle_net, Features)
    |> Keyword.fetch!(:valid_contexts)
  end

end
