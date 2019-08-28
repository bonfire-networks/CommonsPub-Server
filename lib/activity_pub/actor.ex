# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.Actor do
  @moduledoc """
  Functions for dealing with ActivityPub actors
  """
  require Ecto.Query

  alias ActivityPub.Fetcher
  alias ActivityPub.Object
  alias ActivityPub.SQL.Query

  alias Ecto.Changeset
  alias Ecto.Query, as: EQuery
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

  def get_public_key_for_ap_id(actor_id) do
    with {:ok, actor} <- Fetcher.fetch_object_from_id(actor_id),
         {:ok, public_key} <- public_key_from_data(actor.data) do
      {:ok, public_key}
    else
      _ -> :error
    end
  end

  def get_by_username(username) do
    query =
      "activity_pub_actor_aspects"
      |> EQuery.where([a], a.preferred_username == ^username)
      |> EQuery.select([a], a.local_id)

    case Repo.one(query) do
      nil ->
        {:error, "Not found"}

      id ->
        actor =
          ActivityPub.get_by_local_id(id, aspect: :actor)
          |> Query.preload_assoc(:all)

        {:ok, actor}
    end
  end
end
