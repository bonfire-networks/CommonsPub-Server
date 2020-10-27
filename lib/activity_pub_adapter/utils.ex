# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.ActivityPub.Utils do
  alias ActivityPub.Actor
  alias CommonsPub.Threads.Comments

  @public_uri "https://www.w3.org/ns/activitystreams#Public"

  def public_uri() do
    @public_uri
  end

  def ap_base_url() do
    CommonsPub.ActivityPub.Adapter.base_url() <> System.get_env("AP_BASE_PATH", "/pub")
  end

  def check_local(%{is_local: true}) do
    # publish if explicitly known to be local
    true
  end

  def check_local(%{character: %{peer_id: nil}}) do
    # publish local characters
    true
  end

  def check_local(%{creator: %{character: %{peer_id: nil}}}) do
    # publish if author is local
    true
  end

  def check_local(_), do: false

  def get_actor_username(%{preferred_username: u}) when is_binary(u),
    do: u

  def get_actor_username(%{character: %{preferred_username: u}}) when is_binary(u),
    do: u

  def get_actor_username(%{character: %Ecto.Association.NotLoaded{}} = obj) do
    get_actor_username(Map.get(CommonsPub.Repo.maybe_preload(obj, :character), :character))
  end

  def get_actor_username(u) when is_binary(u),
    do: u

  def generate_actor_url(u) when is_binary(u) and u != "",
    do: ap_base_url() <> "/actors/" <> u

  def generate_actor_url(u),
    do: generate_actor_url(get_actor_username(u))

  @doc "Get canonical URL if set, or generate one"

  # def get_actor_canonical_url(%{actor: actor}) do
  #   get_actor_canonical_url(actor)
  # end

  def get_actor_canonical_url(%{canonical_url: canonical_url}) when not is_nil(canonical_url) do
    canonical_url
  end

  def get_actor_canonical_url(%{character: %{canonical_url: canonical_url}})
      when not is_nil(canonical_url) do
    canonical_url
  end

  def get_actor_canonical_url(%{character: %Ecto.Association.NotLoaded{}} = obj) do
    get_actor_canonical_url(Map.get(CommonsPub.Repo.maybe_preload(obj, :character), :character))
  end

  def get_actor_canonical_url(actor) do
    generate_actor_url(actor)
  end

  @doc "Generate canonical URL for local object"
  def generate_object_ap_id(%{id: id}) do
    "#{ap_base_url()}/objects/#{id}"
  end

  def generate_object_ap_id(id) when is_binary(id) or is_number(id) do
    "#{ap_base_url()}/objects/#{id}"
  end

  def generate_object_ap_id(_) do
    nil
  end

  @doc "Get canonical URL for object"
  def get_object_canonical_url(%{canonical_url: canonical_url}) when not is_nil(canonical_url) do
    canonical_url
  end

  def get_object_canonical_url(object) do
    generate_object_ap_id(object)
  end

  def get_raw_character_by_username(username) do
    # FIXME: this should be only one query, and support other types (or two, using pointers?)
    with {:error, _e} <- CommonsPub.Users.one([:default, username: username]),
         {:error, _e} <- CommonsPub.Communities.one([:default, username: username]),
         {:error, _e} <- CommonsPub.Collections.one([:default, username: username]),
         {:error, _e} <- CommonsPub.Characters.one([:default, username: username]) do
      {:error, "not found"}
    end
  end

  def get_raw_character_by_id(id) do
    # FIXME: this should be only one query, and support other types (or two, using pointers?)
    with {:error, _e} <- CommonsPub.Users.one([:default, id: id]),
         {:error, _e} <- CommonsPub.Communities.one([:default, id: id]),
         {:error, _e} <- CommonsPub.Collections.one([:default, id: id]) do
      {:error, "not found"}
    end
  end

  def get_raw_actor_by_ap_id(ap_id) do
    # FIXME: this should not query the AP db
    with {:ok, actor} <- ActivityPub.Actor.get_or_fetch_by_ap_id(ap_id),
         {:ok, actor} <- get_raw_character_by_username(actor.username) do
      {:ok, actor}
    else
      {:error, e} -> {:error, e}
    end
  end

  def get_creator_ap_id(%{creator_id: creator_id}) when not is_nil(creator_id) do
    with {:ok, %{ap_id: ap_id}} <- ActivityPub.Actor.get_cached_by_local_id(creator_id) do
      ap_id
    else
      {:error, _} -> nil
    end
  end

  def get_creator_ap_id(_), do: nil

  def get_context_ap_id(%{context_id: context_id}) when not is_nil(context_id) do
    with {:ok, %{ap_id: ap_id}} <- ActivityPub.Actor.get_cached_by_local_id(context_id) do
      ap_id
    else
      _ -> nil
    end
  end

  def get_context_ap_id(_), do: nil

  def determine_recipients(actor, comment) do
    determine_recipients(actor, comment, [public_uri()], [actor.data["followers"]])
  end

  def determine_recipients(actor, comment, parent) do
    if(is_map(parent) and Map.has_key?(parent, :id)) do
      case ActivityPub.Actor.get_cached_by_local_id(parent.id) do
        {:ok, parent_actor} ->
          determine_recipients(actor, comment, [parent_actor.ap_id, public_uri()], [
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
          actor.pointer_id
        else
          _ -> nil
        end

      %ActivityPub.Object{} = object ->
        object.pointer_id
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

  def maybe_fix_image_object(url) when is_binary(url), do: url
  def maybe_fix_image_object(%{"url" => url}), do: url
  def maybe_fix_image_object(_), do: nil

  def maybe_create_image_object(url, _actor) when is_nil(url), do: nil

  def maybe_create_image_object(url, actor) do
    case CommonsPub.Uploads.upload(CommonsPub.Uploads.ImageUploader, actor, %{url: url}, %{}) do
      {:ok, upload} -> upload.id
      {:error, _} -> nil
    end
  end

  def maybe_create_image_object(url) when not is_nil(url) do
    %{
      "type" => "Image",
      "url" => url
    }
  end

  def maybe_create_image_object(_), do: nil

  def maybe_create_icon_object(url, _actor) when is_nil(url), do: nil

  def maybe_create_icon_object(url, actor) do
    case CommonsPub.Uploads.upload(CommonsPub.Uploads.IconUploader, actor, %{url: url}, %{}) do
      {:ok, upload} -> upload.id
      {:error, _} -> nil
    end
  end
end
