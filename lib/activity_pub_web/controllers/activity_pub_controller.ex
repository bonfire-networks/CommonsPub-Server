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

  alias ActivityPub.SQL.Query

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

  #FIXME: these might be possible with only one SQL query returning the result from the base entity
  def outbox(conn, %{"id" => id}) do
    id = String.to_integer(id)

    case ActivityPub.get_by_local_id(id) do
      entity when is_local(entity) ->
        entity =
          entity
          |> Query.preload_aspect(:actor)
          |> Query.preload_assoc(:outbox)

        outbox_entity =
          ActivityPub.get_by_id(entity.outbox.id)
          |> Query.preload_aspect(:all)
          |> Query.preload_assoc(:all)

        render(conn, "show.json", entity: outbox_entity)

      _ ->
        send_resp(conn, :not_found, "")
    end
  end

  def followers(conn, %{"id" => id}) do
    id = String.to_integer(id)

    case ActivityPub.get_by_local_id(id) do
      entity when is_local(entity) ->
        entity =
          entity
          |> Query.preload_aspect(:actor)
          |> Query.preload_assoc(:followers)

        followers_entity =
          ActivityPub.get_by_id(entity.followers.id)
          |> Query.preload_aspect(:all)
          |> Query.preload_assoc(:all)

        render(conn, "show.json", entity: followers_entity)

      _ ->
        send_resp(conn, :not_found, "")
    end
  end

  def following(conn, %{"id" => id}) do
    id = String.to_integer(id)

    case ActivityPub.get_by_local_id(id) do
      entity when is_local(entity) ->
        entity =
          entity
          |> Query.preload_aspect(:actor)
          |> Query.preload_assoc(:following)

        following_entity =
          ActivityPub.get_by_id(entity.following.id)
          |> Query.preload_aspect(:all)
          |> Query.preload_assoc(:all)

        render(conn, "show.json", entity: following_entity)

      _ ->
        send_resp(conn, :not_found, "")
    end
  end

  def liked(conn, %{"id" => id}) do
    id = String.to_integer(id)

    case ActivityPub.get_by_local_id(id) do
      entity when is_local(entity) ->
        entity =
          entity
          |> Query.preload_aspect(:actor)
          |> Query.preload_assoc(:liked)

        liked_entity =
          ActivityPub.get_by_id(entity.liked.id)
          |> Query.preload_aspect(:all)
          |> Query.preload_assoc(:all)

        render(conn, "show.json", entity: liked_entity)

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
end
