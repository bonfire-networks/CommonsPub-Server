defmodule MoodleNet.ActivityPub.Utils do
  @public_uri "https://www.w3.org/ns/activitystreams#Public"

  def determine_recipients(actor, parent) do
    case ActivityPub.Actor.get_by_username(parent.preferred_username) do
      {:ok, parent_actor} ->
        to = [parent_actor.ap_id, @public_uri]
        cc = actor.data["followers"]
        {to, cc}

      _ ->
        to = [@public_uri]
        cc = actor.data["followers"]
        {to, cc}
    end
  end

  def get_in_reply_to(comment) do
    reply_id = Map.get(comment, :reply_to_id)
    if reply_id do
      ActivityPub.Object.get_by_pointer_id(reply_id)
    else
      nil
    end
  end

  def get_parent_id(parent) do
    case ActivityPub.Object.get_by_pointer_id(parent.id) do
      nil ->
        case ActivityPub.Actor.get_by_username(parent.preferred_username) do
          {:ok, actor} -> actor.ap_id
          {:error, e} -> {:error, e}
        end

      object ->
        object.data["id"]
    end
  end
end
