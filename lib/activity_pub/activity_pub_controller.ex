defmodule ActivityPubWeb.ActivityPubController do
  use MoodleNetWeb, :controller
  alias MoodleNet.{User}
  alias ActivityPub.{ObjectView, UserView}
  alias ActivityPub.Object
  alias ActivityPub
  alias MoodleNetWeb.Federator

  require Logger

  action_fallback(:errors)

  # There are many endpoints here, however not all of them are used:
  #
  # activity_pub_path  GET     /users/:nickname/followers                  ActivityPubWeb.ActivityPubController :followers
  # activity_pub_path  GET     /users/:nickname/following                  ActivityPubWeb.ActivityPubController :following
  # activity_pub_path  GET     /users/:nickname/outbox                     ActivityPubWeb.ActivityPubController :outbox
  # activity_pub_path  POST    /users/:nickname/inbox                      ActivityPubWeb.ActivityPubController :inbox
  # activity_pub_path  POST    /inbox                                      ActivityPubWeb.ActivityPubController :inbox
  #
  # So we don't know if the rest of them are working.
  # I don't understand the last one either: an inbox is owned by an actor
  #
  # ActivityPub defines the following endpoints:
  #
  # object: get object info (an actor is an object, so they may be included here, activities too)
  # followers: (done) of a user
  # following: (done) of a user
  # get outbox: (done) activities published by a user
  # post outbox: client API to create activities
  # get inbox: activities received by the actor
  # post inbox (done) receive foreign activities from a federated server
  # liked: by actor
  # likes: in an object
  # public: all public activities in the server
  # post sharedInbox: publish public activities and activities sent to followers.
  # get sharedInbox: list public activities and activities sent to followers.
  #

  # It does not seem to be used
  def user(conn, %{"nickname" => nickname}) do
    with %User{} = user <- User.get_cached_by_nickname(nickname),
         # Don't understand this, why is not just generated when the user is created?
         # This happening in almost in each endpoint, but it also repeated in the views!!
         {:ok, user} <- MoodleNet.Signature.ensure_keys_present(user) do
      conn
      |> put_resp_header("content-type", "application/activity+json")
      |> json(UserView.render("user.json", %{user: user}))
    else
      nil -> {:error, :not_found}
    end
  end

  # It does not seem to be used
  # Only checks if public? what about a private object fetched by the owner or a `to` or `cc` user
  def object(conn, %{"uuid" => uuid}) do
    with ap_id <- activity_pub_url(conn, :object, uuid),
         %Object{} = object <- Object.get_cached_by_ap_id(ap_id),
         {_, true} <- {:public?, ActivityPub.is_public?(object)} do
      conn
      |> put_resp_header("content-type", "application/activity+json")
      |> json(ObjectView.render("object.json", %{object: object}))
    else
      {:public?, false} ->
        {:error, :not_found}
    end
  end

  def following(conn, %{"nickname" => nickname, "page" => page}) do
    with %User{} = user <- User.get_cached_by_nickname(nickname),
         # Ensure keys again
         {:ok, user} <- MoodleNet.Signature.ensure_keys_present(user) do
      {page, _} = Integer.parse(page)

      # We don't pass the following users to the view.
      # The view should not make any query.
      # Either pagination
      conn
      |> put_resp_header("content-type", "application/activity+json")
      |> json(UserView.render("following.json", %{user: user, page: page}))
    end
  end

  # This is repeated, we can join those two functions
  # If not page then is the page 1 (or 0)
  def following(conn, %{"nickname" => nickname}) do
    with %User{} = user <- User.get_cached_by_nickname(nickname),
         # Ensure keys again
         {:ok, user} <- MoodleNet.Signature.ensure_keys_present(user) do
      conn
      |> put_resp_header("content-type", "application/activity+json")
      |> json(UserView.render("following.json", %{user: user}))
    end
  end

  def followers(conn, %{"nickname" => nickname, "page" => page}) do
    with %User{} = user <- User.get_cached_by_nickname(nickname),
         # Ensure keys again
         {:ok, user} <- MoodleNet.Signature.ensure_keys_present(user) do
      {page, _} = Integer.parse(page)

      # Again queries and pagination in the view
      conn
      |> put_resp_header("content-type", "application/activity+json")
      |> json(UserView.render("followers.json", %{user: user, page: page}))
    end
  end

  # This is repeated, we can join those two functions
  # If not page then is the page 1 (or 0)
  def followers(conn, %{"nickname" => nickname}) do
    with %User{} = user <- User.get_cached_by_nickname(nickname),
         # Ensure keys again
         {:ok, user} <- MoodleNet.Signature.ensure_keys_present(user) do
      conn
      |> put_resp_header("content-type", "application/activity+json")
      |> json(UserView.render("followers.json", %{user: user}))
    end
  end

  def outbox(conn, %{"nickname" => nickname, "max_id" => max_id}) do
    with %User{} = user <- User.get_cached_by_nickname(nickname),
         # Ensure keys again
         {:ok, user} <- MoodleNet.Signature.ensure_keys_present(user) do
      # Again queries and pagination in the view
      conn
      |> put_resp_header("content-type", "application/activity+json")
      |> json(UserView.render("outbox.json", %{user: user, max_id: max_id}))
    end
  end

  # This is unneeded we can use the following in the previous function:
  # max_id = Map.get(params, "max_id")
  def outbox(conn, %{"nickname" => nickname}) do
    outbox(conn, %{"nickname" => nickname, "max_id" => nil})
  end

  # Cool! Seems like a previous plug validate the signture: MoodleNetWeb.Plugs,HTTPSignaturePlug
  # TODO: Ensure that this inbox is a recipient of the message
  def inbox(%{assigns: %{valid_signature: true}} = conn, params) do
    # So this is handle in Federator asynchronously
    # Which calls Transmogrifier.handle_incoming
    # The code following this is already documented
    Federator.enqueue(:incoming_ap_doc, params)
    json(conn, "ok")
  end

  def inbox(conn, params) do
    Logger.info("Signature error - make sure you are forwarding the HTTP Host header!")
    Logger.info("Could not validate #{params["actor"]}")
    Logger.info(inspect(conn.req_headers))

    json(conn, "ok")
  end

  def errors(conn, {:error, :not_found}) do
    conn
    |> put_status(404)
    |> json("Not found")
  end

  def errors(conn, _e) do
    conn
    |> put_status(500)
    |> json("error")
  end
end
