# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPub.Fetcher do
  @moduledoc """
  Handles fetching AS2 objects from remote instances.
  """

  alias ActivityPub.HTTP
  alias ActivityPubWeb.Transmogrifier
  require Logger

  @doc """
  Checks if an object exists in the database and fetches it if it doesn't.
  """
  def fetch_object_from_id(id) do
    if entity = ActivityPub.get_by_id(id) do
      {:ok, entity}
    else
      with {:ok, data} <- fetch_remote_object_from_id(id),
           {:ok, data} <- check_object_type(data),
           {:ok, object} <- Transmogrifier.handle_incoming(data),
           {:ok} <- check_if_public(object.public) do
        {:ok, object}
      else
        {:error, e} -> {:error, e}
      end
    end
  end

  @doc """
  Fetches an AS2 object from remote AP ID.
  """
  def fetch_remote_object_from_id(id) do
    Logger.info("Fetching object #{id} via AP")

    with true <- String.starts_with?(id, "http"),
         {:ok, %{body: body, status: code}} when code in 200..299 <-
           HTTP.get(
             id,
             [{:Accept, "application/activity+json"}]
           ),
         {:ok, data} <- Jason.decode(body) do
      {:ok, data}
    else
      {:ok, %{status: code}} when code in [404, 410] ->
        {:error, "Object has been deleted"}

      e ->
        {:error, e}
    end
  end

  @supported_types ["Note", "Article", "Person"]
  defp check_object_type(data) do
    if data["type"] in @supported_types do
      {:ok, data}
    else
      {:error, "Unsupported type"}
    end
  end

  defp check_if_public(public) when public == true, do: {:ok}

  defp check_if_public(_public), do: {:error, "Not public"}
end
