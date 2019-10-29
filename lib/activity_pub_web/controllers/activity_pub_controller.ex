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

  require Logger

  alias ActivityPub.Actor
  alias ActivityPub.Fetcher
  alias ActivityPub.Object
  alias ActivityPubWeb.ActorView
  alias ActivityPubWeb.Federator
  alias ActivityPubWeb.ObjectView

  def object(conn, %{"uuid" => uuid}) do
    with ap_id <- Routes.activity_pub_url(conn, :object, uuid),
         %Object{} = object <- Object.get_by_ap_id(ap_id),
         true <- object.public do
      conn
      |> put_resp_header("content-type", "application/activity+json")
      |> json(ObjectView.render("object.json", %{object: object}))
    else
      _->
        {:error, :not_found}
    end
  end

  def actor(conn, %{"username" => username}) do
    with {:ok, actor} <- Actor.get_by_username(username) do
      conn
      |> put_resp_header("content-type", "application/activity+json")
      |> json(ActorView.render("actor.json", %{actor: actor}))
    else
      {:error, _e} -> {:error, :not_found}
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
