# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.Actor do
  @moduledoc """
  Functions for dealing with ActivityPub actors
  """

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

  def get_public_key_for_ap_id(actor_id) do
    with {:ok, actor} <- Fetcher.fetch_object_from_id(actor_id),
         {:ok, public_key} <- public_key_from_data(actor.data) do
      {:ok, public_key}
    else
      _ -> :error
    end
  end
end
