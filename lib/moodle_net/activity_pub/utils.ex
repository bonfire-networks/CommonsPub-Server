# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.ActivityPub.Utils do
  @public_uri "https://www.w3.org/ns/activitystreams#Public"

  def determine_recipients(actor, parent) do
    case ActivityPub.Actor.get_cached_by_local_id(parent.id) do
      {:ok, parent_actor} ->
        to = [parent_actor.ap_id, @public_uri]
        cc = [actor.data["followers"]]
        {to, cc}

      _ ->
        to = [@public_uri]
        cc = [actor.data["followers"]]
        {to, cc}
    end
  end

  def get_in_reply_to(comment) do
    reply_id = Map.get(comment, :reply_to_id)

    if reply_id do
      object = ActivityPub.Object.get_by_pointer_id(reply_id)
      object.data["id"]
    else
      nil
    end
  end

  def get_object_ap_id(object) do
    case ActivityPub.Object.get_by_pointer_id(object.id) do
      nil ->
        case ActivityPub.Actor.get_cached_by_local_id(object.id) do
          {:ok, actor} -> actor.ap_id
          {:error, e} -> {:error, e}
        end

      object ->
        object.data["id"]
    end
  end

  def get_object(object) do
    case ActivityPub.Object.get_by_pointer_id(object.id) do
      nil ->
        case ActivityPub.Actor.get_cached_by_local_id(object.id) do
          {:ok, actor} -> actor
          {:error, e} -> {:error, e}
        end

      object ->
        object
    end
  end

  def get_pointer_id_by_ap_id(ap_id) do
    case ActivityPub.Object.get_by_ap_id(ap_id) do
      nil ->
        # Might be a local actor
        with {:ok, actor} <- ActivityPub.Actor.get_cached_by_ap_id(ap_id) do
          actor.mn_pointer_id
        else
          nil -> nil
        end

      %ActivityPub.Object{} = object ->
        object.mn_pointer_id
    end
  end
end
