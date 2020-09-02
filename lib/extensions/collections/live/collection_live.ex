defmodule CommonsPub.Web.CollectionLive do
  use CommonsPub.Web, :live_view

  import CommonsPub.Web.Helpers.Common

  alias CommonsPub.Web.Helpers.{Collections, Profiles}

  alias CommonsPub.Web.CollectionLive.{
    CollectionActivitiesLive,
    CollectionFollowersLive,
    CollectionResourcesLive,
    CollectionDiscussionsLive
  }

  # FIXME
  # def mount(%{auth_token: auth_token}, socket) do
  #   IO.inspect(live_mount_user: auth_token)
  #   {:ok, assign_new(socket, :auth_token, fn -> auth_token end)}
  # end

  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)

    {:ok,
     socket
     |> assign(
       page_title: "Collection",
       selected_tab: "resources",
       current_user: socket.assigns.current_user
     )}
  end

  def handle_params(%{"tab" => tab} = params, _url, socket) do
    collection = Collections.collection_load(socket, params, socket.assigns.current_user)

    {:noreply,
     assign(socket,
       selected_tab: tab,
       collection: collection,
       current_context: collection,
       current_user: socket.assigns.current_user
     )}
  end

  def handle_params(%{} = params, _url, socket) do
    collection = Collections.collection_load(socket, params, socket.assigns.current_user)

    {:noreply,
     assign(socket,
       collection: collection,
       current_context: collection,
       current_user: socket.assigns.current_user
     )}
  end

  def handle_event("flag", %{"message" => message} = _args, socket) do
    {:ok, flag} =
      CommonsPub.Web.GraphQL.FlagsResolver.create_flag(
        %{context_id: socket.assigns.collection.id, message: message},
        %{
          context: %{current_user: socket.assigns.current_user}
        }
      )

    # TODO: error handling

    {
      :noreply,
      socket
      |> put_flash(:info, "Your flag will be revied by an admin!")
      #  |> push_patch(to: "/&" <> socket.assigns.community.username)
    }
  end

  def handle_event("follow", _data, socket) do
    _f =
      CommonsPub.Web.GraphQL.FollowsResolver.create_follow(
        %{context_id: socket.assigns.collection.id},
        %{
          context: %{current_user: socket.assigns.current_user}
        }
      )

    # TODO: error handling

    {
      :noreply,
      socket
      |> put_flash(:info, "Joined!")
      |> assign(collection: socket.assigns.collection |> Map.merge(%{is_followed: true}))
      #  |> push_patch(to: "/&" <> socket.assigns.community.username)
    }
  end

  def handle_event("unfollow", _data, socket) do
    _uf = Profiles.unfollow(socket.assigns.current_user, socket.assigns.collection.id)

    # TODO: error handling

    {
      :noreply,
      socket
      |> assign(collection: socket.assigns.collection |> Map.merge(%{is_followed: false}))
      |> put_flash(:info, "Left...")
    }
  end

  def handle_event("edit_collection", %{"name" => name} = data, socket) do
    if(is_nil(name) or !Map.has_key?(socket.assigns, :current_user)) do
      {:noreply,
       socket
       |> put_flash(:error, "Please enter a name...")}
    else
      changes = input_to_atoms(data)

      {:ok, collection} =
        CommonsPub.Web.GraphQL.CollectionsResolver.update_collection(
          %{collection: changes, collection_id: socket.assigns.collection.id},
          %{
            context: %{current_user: socket.assigns.current_user}
          }
        )

      # TODO: handle errors

      if(collection) do
        collection =
          Profiles.prepare(collection, %{
            icon: true,
            image: true,
            actor: true,
            is_followed_by: socket.assigns.current_user
          })

        {
          :noreply,
          socket
          |> assign(collection: collection)
          |> put_flash(:info, "Collection updated !")
          # change redirect
        }
      else
        {
          :noreply,
          socket
          #  |> push_patch(to: "/&" <> socket.assigns.community.username)
        }
      end
    end
  end

  @doc """
  Forward PubSub activities in timeline to our timeline component
  """
  def handle_info({:pub_feed_activity, activity}, socket),
    do:
      CommonsPub.Web.Helpers.Activites.pubsub_activity_forward(
        activity,
        CollectionActivitiesLive,
        :collection_timeline,
        socket
      )

  defp link_body(name, icon) do
    assigns = %{name: name, icon: icon}

    ~L"""
      <i class="<%= @icon %>"></i>
      <%= @name %>
    """
  end
end
