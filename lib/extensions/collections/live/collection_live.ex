defmodule MoodleNetWeb.CollectionLive do
  use MoodleNetWeb, :live_view

  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.Helpers.{Collections, Profiles}
  alias MoodleNetWeb.GraphQL.CollectionsResolver

  alias MoodleNetWeb.CommunityLive.{
    CommunityWriteLive
  }

  alias MoodleNetWeb.CollectionLive.{
    CollectionActivitiesLive,
    CollectionFollowersLive,
    CollectionResourcesLive,
    CollectionDiscussionsLive
  }

  alias MoodleNetWeb.Component.{
    HeaderLive,
    AboutLive,
    TabNotFoundLive
  }

  alias MoodleNet.{
    Repo
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
    IO.inspect(tab)

    {:noreply,
     assign(socket,
       selected_tab: tab,
       collection: collection,
       current_context: collection,
       current_user: socket.assigns.current_user
     )}
  end

  def handle_params(%{} = params, url, socket) do
    collection = Collections.collection_load(socket, params, socket.assigns.current_user)

    IO.inspect(collection: collection)

    {:noreply,
     assign(socket,
       collection: collection,
       current_context: collection,
       current_user: socket.assigns.current_user
     )}
  end

  def handle_event("flag", %{"message" => message} = _args, socket) do
    {:ok, flag} =
      MoodleNetWeb.GraphQL.FlagsResolver.create_flag(
        %{context_id: socket.assigns.collection.id, message: message},
        %{
          context: %{current_user: socket.assigns.current_user}
        }
      )

    IO.inspect(flag, label: "FLAG")

    # IO.inspect(f)
    # TODO: error handling

    {
      :noreply,
      socket
      |> put_flash(:info, "Your flag will be revied by an admin!")
      #  |> push_patch(to: "/&" <> socket.assigns.community.username)
    }
  end

  def handle_event("follow", _data, socket) do
    f =
      MoodleNetWeb.GraphQL.FollowsResolver.create_follow(
        %{context_id: socket.assigns.collection.id},
        %{
          context: %{current_user: socket.assigns.current_user}
        }
      )

    # IO.inspect(f)
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
    uf = Profiles.unfollow(socket.assigns.current_user, socket.assigns.collection.id)

    # IO.inspect(uf)
    # TODO: error handling

    {
      :noreply,
      socket
      |> assign(collection: socket.assigns.collection |> Map.merge(%{is_followed: false}))
      |> put_flash(:info, "Left...")
    }
  end

  def handle_event("edit_collection", %{"name" => name} = data, socket) do
    # IO.inspect(data, label: "DATA")

    if(is_nil(name) or !Map.has_key?(socket.assigns, :current_user)) do
      {:noreply,
       socket
       |> put_flash(:error, "Please enter a name...")}
    else
      changes = input_to_atoms(data)

      {:ok, collection} =
        MoodleNetWeb.GraphQL.CollectionsResolver.update_collection(
          %{collection: changes, collection_id: socket.assigns.collection.id},
          %{
            context: %{current_user: socket.assigns.current_user}
          }
        )

      # TODO: handle errors
      # IO.inspect(community, label: "community updated")

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

  defp link_body(name, icon) do
    assigns = %{name: name, icon: icon}

    ~L"""
      <i class="<%= @icon %>"></i>
      <%= @name %>
    """
  end
end
