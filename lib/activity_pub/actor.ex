# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.Actor do
  @moduledoc """
  Functions for dealing with ActivityPub actors.
  """
  require Ecto.Query

  alias ActivityPub.Actor
  alias ActivityPub.Adapter
  alias ActivityPub.Fetcher
  alias ActivityPub.Keys
  alias ActivityPub.WebFinger
  alias ActivityPub.Object
  alias ActivityPubWeb.Transmogrifier
  alias MoodleNet.Repo

  @type t :: %Actor{}

  defstruct [:id, :data, :local, :keys, :ap_id, :username]

  @doc """
  Updates an existing actor struct by its AP ID.
  """
  @spec update_actor(String.t()) :: {:ok, Actor.t()} | {:error, any()}
  def update_actor(actor_id) do
    # TODO: make better
    with {:ok, data} <- Fetcher.fetch_remote_object_from_id(actor_id),
         # Create fake activity and handle it through transmogrifier
         # to easily pass data to the host database.
         activity <- %{"type" => "Update", "actor" => actor_id, "object" => data},
         {:ok, _activity} <- Transmogrifier.handle_incoming(activity) do
      # Return actor
      get_by_ap_id(actor_id)
    end
  end

  defp public_key_from_data(%{"publicKey" => %{"publicKeyPem" => public_key_pem}}) do
    key =
      public_key_pem
      |> :public_key.pem_decode()
      |> hd()
      |> :public_key.pem_entry_decode()

    {:ok, key}
  end

  defp public_key_from_data(_), do: {:error, "Key not found"}

  @doc """
  Fetches the public key for given actor AP ID.
  """
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

  @doc """
  Fetches a remote actor by username in `username@domain.tld` format
  """
  def fetch_by_username(username) do
    with {:ok, %{"id" => ap_id}} when not is_nil(ap_id) <- WebFinger.finger(username) do
      get_remote_actor(ap_id)
    else
      _e -> {:error, "No AP id in WebFinger"}
    end
  end

  @doc """
  Tries to get a local actor by username or tries to fetch it remotely if username is provided in `username@domain.tld' format.
  """
  def get_or_fetch_by_username(username) do
    with {:ok, actor} <- get_by_username(username) do
      {:ok, actor}
    else
      _e ->
        with [_nick, _domain] <- String.split(username, "@"),
             {:ok, actor} <- fetch_by_username(username) do
          {:ok, actor}
        else
          _e -> {:error, "not found " <> username}
        end
    end
  end

  defp username_from_ap_id(ap_id) do
    ap_id
    |> String.split("/")
    |> List.last()
  end

  defp get_local_actor(ap_id) do
    username = username_from_ap_id(ap_id)
    get_by_username(username)
  end

  defp get_remote_actor(ap_id) do
    with {:ok, actor} <- Fetcher.fetch_object_from_id(ap_id),
         false <- check_if_time_to_update(actor),
         actor <- format_remote_actor(actor) do
      Adapter.maybe_create_remote_actor(actor)
      {:ok, actor}
    else
      true ->
        update_actor(ap_id)

      {:error, e} ->
        {:error, e}
    end
  end

  @doc """
  Fetches a local actor given its preferred username.
  """
  def get_by_username(username) do
    with {:ok, actor} <- Adapter.get_actor_by_username(username),
         actor <- format_local_actor(actor) do
      {:ok, actor}
    else
      _e -> {:error, "not found"}
    end
  end

  @doc """
  Fetches an actor given its AP ID.

  Remote actors are first checked if they exist in database and are fetched remotely if they don't.

  Remote actors are also automatically updated every 24 hours.
  """
  @spec get_by_ap_id(String.t()) :: {:ok, Actor.t()} | {:error, any()}
  def get_by_ap_id(ap_id) do
    host = URI.parse(ap_id).host

    if host == System.get_env("HOSTNAME", MoodleNetWeb.Endpoint.host()) do
      get_local_actor(ap_id)
    else
      get_remote_actor(ap_id)
    end
  end

  def get_by_ap_id!(ap_id) do
    {:ok, actor} = get_by_ap_id(ap_id)
    actor
  end

  @doc false
  def set_public_key(%{data: data} = actor) do
    {:ok, entity} = Actor.ensure_keys_present(actor)
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

  defp format_local_actor(actor) do
    ap_base_path = System.get_env("AP_BASE_PATH", "/pub")
    id = MoodleNetWeb.base_url() <> ap_base_path <> "/actors/#{actor.preferred_username}"

    type = case actor do
      %MoodleNet.Actors.Actor{} -> "Person"
      %MoodleNet.Communities.Community{} -> "MN:Community"
      %MoodleNet.Collections.Collection{} -> "MN:Collection"
    end

    data = %{
      "type" => type,
      "id" => id,
      "inbox" => "#{id}/inbox",
      "outbox" => "#{id}/outbox",
      "followers" => "#{id}/followers",
      "following" => "#{id}/following",
      "preferredUsername" => actor.preferred_username,
      "name" => actor.latest_revision.revision.name,
      "summary" => actor.latest_revision.revision.summary,
      "icon" => actor.latest_revision.revision.icon,
      "image" => actor.latest_revision.revision.image
    }

    %__MODULE__{
      id: actor.id,
      data: data,
      keys: actor.signing_key,
      local: true,
      ap_id: id,
      username: actor.preferred_username
    }
  end

  defp format_remote_actor(%Object{} = actor) do
    username = actor.data["preferredUsername"] <> "@" <> URI.parse(actor.data["id"]).host

    %__MODULE__{
      id: actor.id,
      data: actor.data,
      keys: nil,
      local: false,
      ap_id: actor.data["id"],
      username: username
    }
  end

  # TODO: write
  def get_external_followers(_actor) do
    []
  end

  # TODO: add bcc
  def remote_users(_actor, %{data: %{"to" => to}} = data) do
    cc = Map.get(data, "cc", [])

    [to, cc]
    |> Enum.concat()
    |> Enum.map(&get_by_ap_id!/1)
    |> Enum.filter(fn actor -> actor && !actor.local end)
  end

  @doc """
  Checks if an actor struct has a non-nil keys field and generates a PEM if it doesn't.
  """
  def ensure_keys_present(actor) do
    if actor.keys do
      {:ok, actor}
    else
      # TODO: move MN specific calls elsewhere
      {:ok, pem} = Keys.generate_rsa_pem()
      {:ok, local_actor} = MoodleNet.Actors.fetch_by_username(actor.data["preferredUsername"])
      {:ok, local_actor} = MoodleNet.Actors.update(local_actor, %{signing_key: pem})
      actor = format_local_actor(local_actor)
      {:ok, actor}
    end
  end

  def delete(%Actor{local: false} = actor) do
    Repo.delete(%Object{
      id: actor.id
    })
  end
end
