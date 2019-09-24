# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.Actor do
  @moduledoc """
  Functions for dealing with ActivityPub actors
  """
  require Ecto.Query

  alias ActivityPub.Adapter
  alias ActivityPub.Fetcher
  alias ActivityPub.Object

  alias Ecto.Changeset
  alias MoodleNet.Repo

  # TODO: make better
  def update_actor(actor_id) do
    with {:ok, %Object{local: false} = actor} <- Fetcher.fetch_object_from_id(actor_id),
         {:ok, data} <- Fetcher.fetch_remote_object_from_id(actor_id) do
      actor
      |> Changeset.change(data: data)
      |> Repo.update()
    end
  end

  def public_key_from_data(%{"publicKey" => %{"publicKeyPem" => public_key_pem}}) do
    key =
      public_key_pem
      |> :public_key.pem_decode()
      |> hd()
      |> :public_key.pem_entry_decode()

    {:ok, key}
  end

  def public_key_from_data(_), do: {:error, "Key not found"}

  def get_public_key_for_ap_id(ap_id) do
    with {:ok, actor} <- get_by_ap_id(ap_id),
         {:ok, public_key} <- public_key_from_data(actor.data) do
      {:ok, public_key}
    else
      _ -> :error
    end
  end

  defp check_if_time_to_update(actor) do
    NaiveDateTime.diff(NaiveDateTime.utc_now(), actor.updated_at) >= 86_400
  end

  defp username_from_ap_id(ap_id) do
    ap_id
    |> String.split("/")
    |> List.last()
  end

  def get_by_username(username) do
    with {:ok, actor} <- Adapter.get_actor_by_username(username),
         actor <- format_local_actor(actor) do
      {:ok, actor}
    end
  end

  def get_local_actor(ap_id) do
    username = username_from_ap_id(ap_id)
    get_by_username(username)
  end

  def get_remote_actor(ap_id) do
    with {:ok, actor} <- Fetcher.fetch_object_from_id(ap_id),
         false <- check_if_time_to_update(actor) do
      {:ok, actor}
    else
      true ->
        update_actor(ap_id)

      {:error, e} ->
        {:error, e}
    end
  end

  @spec get_by_ap_id(String.t()) :: {:ok, Map.t()} | {:error, any()}
  def get_by_ap_id(ap_id) do
    host = URI.parse(ap_id)

    if host == System.get_env("HOSTNAME", MoodleNetWeb.Endpoint.host()) do
      get_local_actor(ap_id)
    else
      get_remote_actor(ap_id)
    end
  end

  def set_public_key(%{data: data} = actor) do
    {:ok, entity} = ActivityPub.Utils.ensure_keys_present(actor)
    {:ok, _, public_key} = ActivityPub.Keys.keys_from_pem(actor.keys)
    public_key = :public_key.pem_entry_encode(:SubjectPublicKeyInfo, public_key)
    public_key = :public_key.pem_encode([public_key])

    public_key = %{
      "id" => "#{actor["id"]}#main-key",
      "owner" => entity["id"],
      "publicKeyPem" => public_key
    }

    data
    |> Map.put("publicKey", public_key)
  end

  def format_local_actor(actor) do
    ap_base_path = System.get_env("AP_BASE_PATH", "/pub")
    id = MoodleNetWeb.base_url() <> ap_base_path <> "/#{actor.preferred_username}"

    data = %{
      "type" => "Person",
      "id" => id,
      "inbox" => "#{id}/inbox",
      "outbox" => "#{id}/outbox",
      "followers" => "#{id}/followers",
      "following" => "#{id}/following",
      "preferredUsername" => actor.preferred_username,
      "name" => actor.name,
      "summary" => actor.summary,
      "icon" => actor.icon,
      "image" => actor.image
    }

    %{
      data: data,
      keys: actor.signing_key,
      local: true
    }
  end
end
