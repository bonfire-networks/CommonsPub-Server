# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2020 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule MoodleNet.ActivityPub.Utils do
  alias ActivityPub.Actor
  alias MoodleNet.Threads.Comments
  @public_uri "https://www.w3.org/ns/activitystreams#Public"

  def determine_recipients(actor, comment) do
    determine_recipients(actor, comment, [@public_uri], [actor.data["followers"]])
  end

  def determine_recipients(actor, comment, parent) do
    if(is_map(parent) and Map.has_key?(parent, :id)) do
      case ActivityPub.Actor.get_cached_by_local_id(parent.id) do
        {:ok, parent_actor} ->
          determine_recipients(actor, comment, [parent_actor.ap_id, @public_uri], [
            actor.data["followers"]
          ])

        _ ->
          determine_recipients(actor, comment)
      end
    else
      determine_recipients(actor, comment)
    end
  end

  def determine_recipients(actor, comment, to, cc) do
    # this doesn't feel very robust
    to =
      unless is_nil(get_in_reply_to(comment)) do
        participants =
          Comments.list_comments_in_thread(comment.thread)
          |> Enum.map(fn comment -> comment.creator_id end)
          |> Enum.map(&ActivityPub.Actor.get_by_local_id!/1)
          |> Enum.filter(fn actor -> actor end)
          |> Enum.map(fn actor -> actor.ap_id end)

        (participants ++ to)
        |> Enum.dedup()
        |> List.delete(Map.get(Actor.get_by_local_id!(actor.id), :ap_id))
      else
        to
      end

    {to, cc}
  end

  def get_in_reply_to(comment) do
    reply_id = Map.get(comment, :reply_to_id)

    if reply_id do
      case ActivityPub.Object.get_cached_by_pointer_id(reply_id) do
        nil ->
          nil

        object ->
          object.data["id"]
      end
    else
      nil
    end
  end

  def get_object_ap_id(object) do
    case ActivityPub.Object.get_cached_by_pointer_id(object.id) do
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
    case ActivityPub.Object.get_cached_by_pointer_id(object.id) do
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
    case ActivityPub.Object.get_cached_by_ap_id(ap_id) do
      nil ->
        # Might be a local actor
        with {:ok, actor} <- ActivityPub.Actor.get_cached_by_ap_id(ap_id) do
          actor.mn_pointer_id
        else
          _ -> nil
        end

      %ActivityPub.Object{} = object ->
        object.mn_pointer_id
    end
  end

  def create_author_object(%{author: nil}) do
    nil
  end

  def create_author_object(%{author: author}) do
    uri = URI.parse(author)

    if uri.host do
      %{"url" => author, "type" => "Person"}
    else
      %{"name" => author, "type" => "Person"}
    end
  end

  def get_author(nil), do: nil

  def get_author(%{"url" => url}), do: url

  def get_author(%{"name" => name}), do: name

  def get_author(author) when is_binary(author), do: author

  @doc "Generate canonical URL for local object"
  def generate_object_ap_id(object) do
    ap_base_path = System.get_env("AP_BASE_PATH", "/pub")

    "#{MoodleNetWeb.base_url()}#{ap_base_path}/objects/#{object.id}"
  end

  @doc "Get canonical URL if set, or generate one"

  def get_actor_canonical_url(%{actor: actor}) do
    get_actor_canonical_url(actor)
  end

  def get_actor_canonical_url(%{canonical_url: canonical_url}) do
    canonical_url
  end

  def get_actor_canonical_url(actor) do
    ActivityPub.Utils.actor_url(actor)
  end

  def get_object_canonical_url(%{canonical_url: canonical_url}) do
    canonical_url
  end

  def get_object_canonical_url(object) do
    ActivityPub.Utils.object_url(object)
  end
end
