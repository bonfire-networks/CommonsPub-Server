defmodule CommonsPub.ActivityPub.Types do

def character_to_actor(actor) do
    type =
      case actor do
        %CommonsPub.Users.User{} -> "Person"
        %CommonsPub.Communities.Community{} -> "Group"
        %CommonsPub.Collections.Collection{} -> "MN:Collection"
        # %CommonsPub.Characters.Character{} -> "CommonsPub:" <> Map.get(actor, :facet, "Character")
        _ -> "CommonsPub:Character"
      end

    actor = CommonsPub.Repo.maybe_preload(actor, [:character, :profile])

    context = CommonsPub.ActivityPub.Utils.get_context_ap_id(actor)

    actor =
      actor
      |> Map.merge(Map.get(actor, :character, %{}))
      |> Map.merge(Map.get(actor, :profile, %{}))

    icon_url = CommonsPub.Uploads.remote_url_from_id(Map.get(actor, :icon_id))

    image_url = CommonsPub.Uploads.remote_url_from_id(Map.get(actor, :image_id))

    id = CommonsPub.ActivityPub.Utils.generate_actor_url(actor)

    username = CommonsPub.ActivityPub.Utils.get_actor_username(actor)

    data = %{
      "type" => type,
      "id" => id,
      "inbox" => "#{id}/inbox",
      "outbox" => "#{id}/outbox",
      "followers" => "#{id}/followers",
      "following" => "#{id}/following",
      "preferredUsername" => username,
      "name" => Map.get(actor, :name),
      "summary" => Map.get(actor, :summary),
      "icon" => CommonsPub.ActivityPub.Utils.maybe_create_image_object(icon_url),
      "image" => CommonsPub.ActivityPub.Utils.maybe_create_image_object(image_url)
    }

    data =
      case data["type"] do
        "Group" ->
          data
          |> Map.put("collections", get_and_format_collections_for_actor(actor))
          |> Map.put("attributedTo", CommonsPub.ActivityPub.Utils.get_creator_ap_id(actor))
          |> Map.put("context", context)

        "MN:Collection" ->
          data
          |> Map.put("resources", get_and_format_resources_for_actor(actor))
          |> Map.put("attributedTo", CommonsPub.ActivityPub.Utils.get_creator_ap_id(actor))
          |> Map.put("context", context)

        _ ->
          data
      end

    %ActivityPub.Actor{
      id: actor.id,
      data: data,
      keys: Map.get(Map.get(actor, :character, actor), :signing_key),
      local: CommonsPub.ActivityPub.Utils.check_local(actor),
      ap_id: id,
      pointer_id: actor.id,
      username: username,
      deactivated: false
    }
  end

    # TODO
  def get_and_format_collections_for_actor(_actor) do
    []
  end

  # TODO
  def get_and_format_resources_for_actor(_actor) do
    []
  end


end
