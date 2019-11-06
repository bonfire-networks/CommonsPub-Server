# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule MoodleNetWeb.GraphQL.CollectionsResolver do
  @moduledoc """
  Performs the GraphQL Collection queries.
  """
  import MoodleNetWeb.GraphQL.MoodleNetSchema
  alias MoodleNet.Collections
  alias MoodleNetWeb.GraphQL.Errors

  def list(args, info), do: to_page(:collection, args, info)

  def fetch(%{collection_id: collection_id}, info) do
  end

  def create(%{collection: attrs, community_id: community_id}, info) do
    # with {:ok, actor} <- current_actor(info),
    #      {:ok, community} <- fetch(comm_id, "MoodleNet:Community"),
    #      attrs = set_icon(attrs),
    #      {:ok, collection} <- MoodleNet.create_collection(actor, community, attrs) do
    #   fields = requested_fields(info)
    #   {:ok, prepare(collection, fields)}
    # end
    # |> Errors.handle_error()
  end

  def update(%{collection: changes, collection_local_id: id}, info) do
    # with {:ok, actor} <- current_actor(info),
    #      {:ok, collection} <- fetch(id, "MoodleNet:Collection"),
    #      {:ok, collection} <- MoodleNet.update_collection(actor, collection, changes) do
    #   fields = requested_fields(info)
    #   {:ok, prepare(collection, fields)}
    # end
    # |> Errors.handle_error()
  end

  def delete(%{local_id: id}, info) do
    # with {:ok, actor} <- current_actor(info),
    #      {:ok, collection} <- fetch(id, "MoodleNet:Collection"),
    #      :ok <- MoodleNet.delete_collection(actor, collection) do
    #   {:ok, true}
    # end
    # |> Errors.handle_error()
  end

end
