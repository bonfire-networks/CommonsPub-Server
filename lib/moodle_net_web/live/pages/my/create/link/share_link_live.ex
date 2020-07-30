defmodule MoodleNetWeb.My.ShareLinkLive do
  use MoodleNetWeb, :live_component

  import MoodleNetWeb.Helpers.Common

  # alias MoodleNetWeb.Helpers.{Profiles, Communities}

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end

  def handle_event("toggle_link", _data, socket) do
    {:noreply, assign(socket, :toggle_link, !socket.assigns.toggle_link)}
  end

  def handle_event("fetch_link", %{"content" => %{"url" => url}} = data, socket)
      when byte_size(url) > 5 do
    if !Map.get(socket.assigns, :fetched_url) or url != Map.get(socket.assigns, :fetched_url) do
      IO.inspect(fetch_url: url)

      fetch =
        with {:ok, fetch} <- MoodleNetWeb.GraphQL.MiscSchema.fetch_web_metadata(%{url: url}, nil) do
          IO.inspect(scraped: fetch)
          fetch
        else
          _ ->
            %{}
        end

      {:noreply,
       socket
       |> assign(fetched_url: url, link_input: fetch)
       |> put_flash(:info, "Fetched link !")}
    else
      IO.inspect(ignore_url: url)
      {:noreply, socket}
    end
  end

  def handle_event("fetch_link", _, socket) do
    {:noreply, socket}
  end

  def handle_event(
        "share_link",
        %{
          "content" => %{"url" => url} = content,
          "name" => name,
          "icon" => icon,
          "context_id" => context_id
        } = data,
        socket
      ) do

        IO.inspect(data, label: "DATAAAAAAAAAAAAA:")
    if(strlen(url) < 5 or strlen(name) < 3 or is_nil(socket.assigns.current_user)) do
      {:noreply,
       socket
       |> put_flash(:error, "Please enter a valid link and give it a name...")}
    else
      # MoodleNetWeb.Plugs.Auth.login(socket, session.current_user, session.token)
      resource = input_to_atoms(data)

      IO.inspect(context_id, label: "context_id CHOOSEN")

      if strlen(context_id) < 1 do
        {:ok, resource} =
          MoodleNetWeb.GraphQL.ResourcesResolver.create_resource(
            %{resource: resource, content: content, icon: icon},
            %{context: %{current_user: socket.assigns.current_user}}
          )

        {:noreply,
         socket
         |> put_flash(:info, "Published!")
         # change redirect
         |> push_redirect(to: "/instance/timeline")}
      else
        {:ok, resource} =
          MoodleNetWeb.GraphQL.ResourcesResolver.create_resource(
            %{context_id: context_id, resource: resource, content: content, icon: icon},
            %{context: %{current_user: socket.assigns.current_user}}
          )

        {:noreply,
         socket
         |> put_flash(:info, "Published!")
         |> push_redirect(to: "/instance/timeline")
        }

        # change redirect
        #  |> push_redirect(to: "/!" <> resource.id)}
      end
    end
  end
end
