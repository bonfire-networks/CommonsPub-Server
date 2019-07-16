# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNetWeb.GraphQL.CommunityResolver do
  import MoodleNetWeb.GraphQL.MoodleNetSchema

  alias MoodleNetWeb.GraphQL.Errors
  require ActivityPub.Guards, as: APG

  def community_list(args, info), do: to_page(:community, args, info)

  def create(%{community: attrs}, info) do
    attrs = set_icon(attrs)

    with {:ok, actor} <- current_actor(info),
         {:ok, community} <- MoodleNet.create_community(actor, attrs) do
      fields = requested_fields(info)
      {:ok, prepare(community, fields)}
    end
    |> Errors.handle_error()
  end

  def update(%{community: changes, community_local_id: id}, info) do
    with {:ok, actor} <- current_actor(info),
         {:ok, community} <- fetch(id, "MoodleNet:Community"),
         {:ok, community} <- MoodleNet.update_community(actor, community, changes) do
      fields = requested_fields(info)
      {:ok, prepare(community, fields)}
    end
    |> Errors.handle_error()
  end

  def delete(%{local_id: id}, info) do
    with {:ok, actor} <- current_actor(info),
         {:ok, community} <- fetch(id, "MoodleNet:Community"),
         :ok <- MoodleNet.delete_community(actor, community) do
      {:ok, true}
    end
    |> Errors.handle_error()
  end

  def join(%{community_local_id: id}, info) do
    with {:ok, actor} <- current_actor(info),
         {:ok, community} <- fetch(id, "MoodleNet:Community") do
      MoodleNet.join_community(actor, community)
    end
    |> Errors.handle_error()
  end

  def undo_join(%{community_local_id: id}, info) do
    with {:ok, actor} <- current_actor(info),
         {:ok, community} <- fetch(id, "MoodleNet:Community") do
      MoodleNet.undo_follow(actor, community)
    end
    |> Errors.handle_error()
  end

  def prepare_community([e | _] = list, fields) when APG.has_type(e, "MoodleNet:Community") do
    list
    |> preload_assoc_cond([:icon], fields)
    |> preload_aspect_cond([:actor_aspect], fields)
    |> Enum.map(&prepare_community(&1, fields))
  end

  def prepare_community(e, fields) when APG.has_type(e, "MoodleNet:Community") do
    e
    |> preload_assoc_cond([:icon], fields)
    |> preload_aspect_cond([:actor_aspect], fields)
    |> prepare_common_fields()
  end
end
