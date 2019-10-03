# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.CollectionResolver do
  @moduledoc """
  Performs the GraphQL Collection queries.
  """
  import MoodleNetWeb.GraphQL.MoodleNetSchema
  alias MoodleNet.Collections
  alias MoodleNetWeb.GraphQL.Errors

  def list(args, info), do: to_page(:collection, args, info)

  def create(%{collection: attrs, community_local_id: comm_id}, info) do
    with {:ok, actor} <- current_actor(info),
         {:ok, community} <- fetch(comm_id, "MoodleNet:Community"),
         attrs = set_icon(attrs),
         {:ok, collection} <- MoodleNet.create_collection(actor, community, attrs) do
      fields = requested_fields(info)
      {:ok, prepare(collection, fields)}
    end
    |> Errors.handle_error()
  end

  def update(%{collection: changes, collection_local_id: id}, info) do
    with {:ok, actor} <- current_actor(info),
         {:ok, collection} <- fetch(id, "MoodleNet:Collection"),
         {:ok, collection} <- MoodleNet.update_collection(actor, collection, changes) do
      fields = requested_fields(info)
      {:ok, prepare(collection, fields)}
    end
    |> Errors.handle_error()
  end

  def delete(%{local_id: id}, info) do
    with {:ok, actor} <- current_actor(info),
         {:ok, collection} <- fetch(id, "MoodleNet:Collection"),
         :ok <- MoodleNet.delete_collection(actor, collection) do
      {:ok, true}
    end
    |> Errors.handle_error()
  end

  def follow(%{collection_local_id: id}, info) do
    with {:ok, actor} <- current_actor(info),
         {:ok, collection} <- fetch(id, "MoodleNet:Collection") do
      MoodleNet.follow_collection(actor, collection)
    end
    |> Errors.handle_error()
  end

  def undo_follow(%{collection_local_id: id}, info) do
    with {:ok, actor} <- current_actor(info),
         {:ok, collection} <- fetch(id, "MoodleNet:Collection") do
      MoodleNet.undo_follow(actor, collection)
    end
    |> Errors.handle_error()
  end

  def like(%{local_id: collection_id}=attrs, info) do
    with {:ok, liker} <- current_actor(info),
         {:ok, collection} <- fetch(collection_id, "MoodleNet:Collection"),
         {:ok, _like} <- Collections.like(liker, collection) do
      {:ok, true}
    end
    |> Errors.handle_error()
  end

  def undo_like(%{local_id: collection_id}, info) do
    with {:ok, actor} <- current_actor(info),
         {:ok, collection} <- fetch(collection_id, "MoodleNet:Collection"),
         {:ok, _like} <- Collections.undo_like(actor, collection) do
      {:ok, true}
    end
    |> Errors.handle_error()
  end

  def flag(%{local_id: collection_id, reason: reason}, info) do
    with {:ok, actor} <- current_actor(info),
         {:ok, collection} <- fetch(collection_id, "MoodleNet:Collection"),
         {:ok, _activity} <- Collections.flag(actor, collection, %{reason: reason}) do
      {:ok, true}
    end
    |> Errors.handle_error()
  end

  def undo_flag(%{local_id: collection_id}, info) do
    with {:ok, actor} <- current_actor(info),
         {:ok, collection} <- fetch(collection_id, "MoodleNet:Collection"),
         {:ok, _activity} <- Collections.undo_flag(actor, collection) do
      {:ok, true}
    end
    |> Errors.handle_error()
  end


end
