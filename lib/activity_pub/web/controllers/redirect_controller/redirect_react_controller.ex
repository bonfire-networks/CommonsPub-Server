# SPDX-License-Identifier: AGPL-3.0-only

defmodule ActivityPubWeb.RedirectController.React do
  @moduledoc """
  Redirects canonical URLs to the appropriate page in the React frontend
  """

  use ActivityPubWeb, :controller
  alias CommonsPub.Threads.Comment
  alias CommonsPub.Collections.Collection
  alias CommonsPub.Communities.Community
  alias CommonsPub.Resources.Resource
  alias CommonsPub.Users.User

  def object(conn, %{"uuid" => uuid}) do
    frontend_base = CommonsPub.Config.get!(:frontend_base_url)

    ap_id = ActivityPubWeb.ActivityPubController.ap_route_helper(uuid)
    object = ActivityPub.Object.get_cached_by_ap_id(ap_id)

    case object do
      %ActivityPub.Object{data: %{"type" => "Create"}} ->
        if is_binary(object.data["object"]) do
          redirect(conn, external: object.data["object"])
        else
          redirect(conn, external: object.data["object"]["id"])
        end

      %ActivityPub.Object{} ->
        with pointer_id when not is_nil(pointer_id) <- Map.get(object, :mn_pointer_id),
             {:ok, pointer} <- CommonsPub.Meta.Pointers.one(id: pointer_id) do
          mn_object = CommonsPub.Meta.Pointers.follow!(pointer)

          case mn_object do
            %Comment{} ->
              redirect(conn, external: frontend_base <> "/thread/" <> mn_object.thread_id)

            %Resource{} ->
              redirect(conn,
                external: frontend_base <> "/collections/" <> mn_object.collection_id
              )

            _ ->
              redirect(conn, external: "#{frontend_base}/404")
          end
        else
          _e -> redirect(conn, external: "#{frontend_base}/404")
        end

      _ ->
        redirect(conn, external: "#{frontend_base}/404")
    end
  end

  def actor(conn, %{"username" => username}) do
    frontend_base = CommonsPub.Config.get!(:frontend_base_url)

    case ActivityPub.Adapter.get_actor_by_username(username) do
      {:ok, %User{} = actor} ->
        redirect(conn, external: frontend_base <> "/user/" <> actor.id)

      {:ok, %Collection{} = actor} ->
        redirect(conn, external: frontend_base <> "/collections/" <> actor.id)

      {:ok, %Community{} = actor} ->
        redirect(conn, external: frontend_base <> "/communities/" <> actor.id)

      {:error, _e} ->
        redirect(conn, external: "#{frontend_base}/404")
    end
  end
end