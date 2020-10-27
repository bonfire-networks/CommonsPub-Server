# SPDX-License-Identifier: AGPL-3.0-only
defmodule CommonsPub.ActivityPub.Adapter do
  @moduledoc """
  Adapter functions delegated from the `ActivityPub` Library
  """
  alias CommonsPub.ActivityPub.Utils
  alias CommonsPub.Workers.APReceiverWorker
  require Logger

  @behaviour ActivityPub.Adapter

  def base_url() do
    CommonsPub.Web.base_url()
  end

  @doc """
  Queue-up incoming activities to be processed by `CommonsPub.Workers.APReceiverWorker`
  """
  def handle_activity(activity) do
    APReceiverWorker.enqueue("handle_activity", %{
      "activity_id" => activity.id,
      "activity" => activity.data
    })
  end

  def get_follower_local_ids(actor) do
    {:ok, actor} = CommonsPub.ActivityPub.Utils.get_raw_character_by_id(actor.pointer_id)
    {:ok, follows} = CommonsPub.Follows.many(context: actor.id)

    follows |> Enum.map(fn follow -> follow.creator_id end)
  end

  def get_following_local_ids(actor) do
    {:ok, actor} = CommonsPub.ActivityPub.Utils.get_raw_character_by_id(actor.pointer_id)
    {:ok, follows} = CommonsPub.Follows.many(creator: actor.id)

    follows |> Enum.map(fn follow -> follow.context_id end)
  end

  def get_actor_by_id(id) do
    case CommonsPub.ActivityPub.Utils.get_raw_character_by_id(id) do
      {:ok, actor} ->
        # IO.inspect(get_raw_character_by_id: actor)
        {:ok, CommonsPub.ActivityPub.Types.character_to_actor(actor)}

      _ ->
        {:error, "not found"}
    end
  end

  def get_actor_by_username(username) do
    case CommonsPub.ActivityPub.Utils.get_raw_character_by_username(username) do
      {:ok, actor} ->
        {:ok, CommonsPub.ActivityPub.Types.character_to_actor(actor)}

      _ ->
        {:error, "not found"}
    end
  end

  def get_actor_by_ap_id(ap_id) do
    case CommonsPub.ActivityPub.Utils.get_raw_actor_by_ap_id(ap_id) do
      {:ok, actor} ->
        {:ok, CommonsPub.ActivityPub.Types.character_to_actor(actor)}

      _ ->
        {:error, "not found"}
    end
  end

  def update_local_actor(actor, params) do
    keys = Map.get(params, :keys)
    params = Map.put(params, :signing_key, keys)
    # FIXME - does it work for characters other than user?
    with {:ok, local_actor} <-
           CommonsPub.Characters.one(username: actor.data["preferredUsername"]),
         {:ok, local_actor} <-
           CommonsPub.Characters.update(%CommonsPub.Users.User{}, local_actor, params),
         {:ok, local_actor} <- get_actor_by_username(local_actor.preferred_username) do
      {:ok, local_actor}
    else
      {:error, e} -> {:error, e}
    end
  end

  def update_remote_actor(actor_object) do
    data = actor_object.data

    with {:ok, actor} <- CommonsPub.ActivityPub.Utils.get_raw_character_by_id(actor_object.pointer_id) do
      # FIXME - support other types
      case actor do
        %CommonsPub.Users.User{} ->
          CommonsPub.ActivityPub.Receiver.update_user(actor, data)

        %CommonsPub.Communities.Community{} ->
          CommonsPub.ActivityPub.Receiver.update_community(actor, data)

        %CommonsPub.Collections.Collection{} ->
          CommonsPub.ActivityPub.Receiver.update_collection(actor, data)
      end
    end
  end

  def maybe_create_remote_actor(actor) do
    host = URI.parse(actor.data["id"]).host
    username = actor.data["preferredUsername"] <> "@" <> host

    case CommonsPub.Characters.one(username: username) do
      {:error, _} ->
        with {:ok, _actor} <-
               CommonsPub.ActivityPub.Receiver.create_remote_actor(actor.data, username) do
          :ok
        else
          _e -> {:error, "Could not create remote actor"}
        end

      _ ->
        :ok
    end
  end
end
