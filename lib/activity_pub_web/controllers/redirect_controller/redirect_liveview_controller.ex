# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubWeb.RedirectController.LiveView do
  @moduledoc """
  Redirects canonical URLs to the appropriate page in the LiveView frontend
  """

  use ActivityPubWeb, :controller
  alias MoodleNet.Threads.Thread
  alias MoodleNet.Threads.Comment
  # alias MoodleNet.Collections.Collection
  alias MoodleNet.Communities.Community
  alias MoodleNet.Resources.Resource
  alias MoodleNet.Users.User

  def object(conn, %{"uuid" => uuid}) do
    with {:ok, pointer} <- Pointers.ULID.cast(uuid),
         {:ok, pointer} <- MoodleNet.Meta.Pointers.one(id: pointer) do
      # try simply using AP id as pointer
      object_pointer_redirect(conn, pointer)
    else
      _ ->
        ap_id = ActivityPubWeb.ActivityPubController.ap_route_helper(uuid)
        object = ActivityPub.Object.get_cached_by_ap_id(ap_id)

        case object do
          %ActivityPub.Object{} ->
            # try using generated AP id
            object_redirect(conn, object, uuid)

          _ ->
            # try with request URL as AP id
            url = current_url(conn)
            object = ActivityPub.Object.get_cached_by_ap_id(url)
            object_redirect(conn, object, uuid)
        end
    end
  end

  def object_redirect(conn, object, uuid) do
    frontend_base = MoodleNet.Config.get!(:base_url)

    case object do
      %ActivityPub.Object{data: %{"type" => "Create"}} ->
        if is_binary(object.data["object"]) do
          redirect(conn, external: object.data["object"])
        else
          redirect(conn, external: object.data["object"]["id"])
        end

      %ActivityPub.Object{} ->
        with pointer_id when not is_nil(pointer_id) <- Map.get(object, :mn_pointer_id),
             {:ok, pointer} <- MoodleNet.Meta.Pointers.one(id: pointer_id) do
          object_pointer_redirect(conn, pointer)
        else
          _e -> redirect(conn, external: "#{frontend_base}/404/ap_has_no_pointer/" <> uuid)
        end

      _ ->
        redirect(conn, external: "#{frontend_base}/404/ap_not_found/" <> uuid)
    end
  end

  def object_pointer_redirect(conn, pointer) do
    frontend_base = MoodleNet.Config.get!(:base_url)

    mn_object = MoodleNet.Meta.Pointers.follow!(pointer)

    case mn_object do
      %Thread{} ->
        redirect(conn, external: frontend_base <> "/!" <> mn_object.id <> "/discuss")

      %Comment{} ->
        redirect(conn,
          external:
            frontend_base <>
              "/!" <> mn_object.thread_id <> "/discuss/" <> mn_object.id <> "#reply"
        )

      %Resource{} ->
        redirect(conn,
          external: frontend_base <> "/+" <> mn_object.collection_id
        )

      %{id: id} ->
        redirect(conn,
          external: frontend_base <> "/!" <> id
        )

      _ ->
        redirect(conn, external: "#{frontend_base}/404/pointer_not_found/" <> pointer)
    end
  end

  def actor(conn, %{"username" => username}) do
    frontend_base = MoodleNet.Config.get!(:frontend_base_url)

    case ActivityPub.Adapter.get_actor_by_username(username) do
      {:ok, %User{preferred_username: preferred_username}} ->
        redirect(conn, external: frontend_base <> "/@" <> preferred_username)

      {:ok, %Community{preferred_username: preferred_username}} ->
        redirect(conn, external: frontend_base <> "/&" <> preferred_username)

      {:ok, %{preferred_username: preferred_username}} ->
        redirect(conn, external: frontend_base <> "/+" <> preferred_username)

      {:ok, %{id: id}} ->
        redirect(conn, external: frontend_base <> "/+" <> id)

      {:ok, _} ->
        redirect(conn, external: frontend_base <> "/+" <> username)

      _ ->
        redirect(conn, external: "#{frontend_base}/404/actor_not_found/" <> username)
    end
  end
end
