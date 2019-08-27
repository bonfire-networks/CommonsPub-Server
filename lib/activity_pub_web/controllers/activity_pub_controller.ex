# MoodleNet: Connecting and empowering educators worldwide
# Copyright © 2018-2019 Moodle Pty Ltd <https://moodle.com/moodlenet/>
# Contains code from Pleroma <https://pleroma.social/> and CommonsPub <https://commonspub.org/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubWeb.ActivityPubController do
  @moduledoc """

  TODO The only endpoints implemented so far are for serving an object by ID, so the ActivityPub API can be used to read information from a MoodleNet server.

  Even though store the data in AS format, some changes need to be applied to the entity before serving it in the AP REST response. This is done in `ActivityPubWeb.ActivityPubView`.
  """

  use ActivityPubWeb, :controller

  import ActivityPub.Guards

  require Logger

  alias ActivityPub.Fetcher
  alias ActivityPub.SQL.Query
  alias ActivityPubWeb.Federator
  alias ActivityPubWeb.Transmogrifier

  def show(conn, %{"id" => id}) do
    id = String.to_integer(id)

    case ActivityPub.get_by_local_id(id) do
      entity when is_local(entity) ->
        entity =
          entity
          |> Query.preload_aspect(:all)
          |> Query.preload_assoc(:all)

        render(conn, "show.json", entity: entity)

      _ ->
        send_resp(conn, :not_found, "")
    end
  end

  def collection_page(conn, %{"id" => id}) do
    id = String.to_integer(id)

    case ActivityPub.get_by_local_id(id) do
      collection when is_local(collection) and has_type(collection, "Collection") ->
        {:ok, entity} = ActivityPub.CollectionPage.new(collection, conn.query_params)
        render(conn, "show.json", entity: entity)

      _ ->
        send_resp(conn, :not_found, "")
    end
  end

  def inbox(%{assigns: %{valid_signature: true}} = conn, params) do
    Federator.incoming_ap_doc(params)
    json(conn, "ok")
  end

  # only accept relayed Creates
  def inbox(conn, %{"type" => "Create"} = params) do
    Logger.info(
      "Signature missing or not from author, relayed Create message, fetching object from source"
    )

    Fetcher.fetch_object_from_id(params["object"]["id"])

    json(conn, "ok")
  end

  def inbox(conn, params) do
    headers = Enum.into(conn.req_headers, %{})

    if String.contains?(headers["signature"], params["actor"]) do
      Logger.info(
        "Signature validation error for: #{params["actor"]}, make sure you are forwarding the HTTP Host header!"
      )

      Logger.info(inspect(conn.req_headers))
    end

    json(conn, dgettext("errors", "error"))
  end
end
