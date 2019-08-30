# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.Policy do
  @moduledoc """
  Module to define if a user can or cannot do an operation
  """
  import ActivityPub.Guards
  alias ActivityPub.SQL.Query

  import MoodleNet, only: [get_community: 1]

  @doc "Check the given policy (an atom naming a policy function)"
  def check(policy, args), do: apply(__MODULE__, policy, args)

  def create_collection?(actor, community, _attrs)
  when has_type(community, "MoodleNet:Community") and has_type(actor, "Person") do
    actor_follows!(actor, community)
  end

  def create_resource?(actor, collection, _attrs)
  when has_type(collection, "MoodleNet:Collection") and has_type(actor, "Person") do
    community = get_community(collection)
    actor_follows!(actor, community)
  end

  def create_comment?(actor, community, _attrs)
  when has_type(community, "MoodleNet:Community") and has_type(actor, "Person") do
    actor_follows!(actor, community)
  end

  def create_comment?(actor, collection, _attrs)
  when has_type(collection, "MoodleNet:Collection") and has_type(actor, "Person") do
    community = get_community(collection)
    actor_follows!(actor, community)
  end

  def like?(actor, , _attrs) when is_() do
  end
  def like?(actor, , _attrs) when is_() do
  end
  def like?(actor, , _attrs) when is_() do
  end
  def like?(actor, , _attrs) when is_() do
  end
  def like?(actor, , _attrs) when is_() do
  end
  def like_comment?(actor, comment, _attrs)
  when has_type(comment, "Note") and has_type(actor, "Person") do
    comment = Query.preload_assoc(comment, [context: [:context]])
    community = get_community(comment)
    actor_follows!(actor, community)
  end

  def like_resource?(actor, resource, _attrs)
  when has_type(resource, "MoodleNet:EducationalResource") and has_type(actor, "Person") do
    resource = Query.preload_assoc(resource, [:context])
    community = get_community(resource)
    actor_follows!(actor, community)
  end

  def like_collection?(actor, collection, _attrs)
  when has_type(collection, "MoodleNet:Collection") and has_type(actor, "Person") do
    collection = Query.preload_assoc(collection, [:context])
    community = get_community(collection)
    actor_follows!(actor, community)
  end

  def flag_comment?(actor, comment, _attrs)
  when has_type(comment, "Note") and has_type(actor, "Person") do
    :ok
  end

  def flag_resource?(actor, resource, _attrs)
  when has_type(resource, "MoodleNet:EducationalResource") and has_type(actor, "Person") do
    :ok
  end
  
  def flag_collection?(actor, collection, _attrs)
  when has_type(collection, "MoodleNet:Collection") and has_type(actor, "Person") do
    :ok
  end

  def flag_community?(actor, community, _attrs)
  when has_type(community, "MoodleNet:Community") and has_type(actor, "Person") do
    :ok
  end

  def flag_user?(actor, user, _attrs)
  when has_type(user, "Person") and has_type(actor, "Person") do
    :ok
  end

  def list_collection_flags?(actor)
  when has_type(actor, "Person"), do: administrator?(actor)

  def list_community_flags?(actor)
  when has_type(actor, "Person"), do: administrator?(actor)

  def list_user_flags?(actor)
  when has_type(actor, "Person"), do: administrator?(actor)

  def list_comment_flags?(actor)
  when has_type(actor, "Person"), do: administrator?(actor)

  def list_resource_flags?(actor)
  when has_type(actor, "Person"), do: administrator?(actor)

  defp actor_follows!(actor, object) do
    if Query.has?(actor, :following, object), do: :ok, else: {:error, :forbidden}
  end

  #### TODO: how do we verify the user's adminship?
  defp administrator?(actor), do: :ok

end
