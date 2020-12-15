defmodule CommonsPub.Web.My.ShareLinkLive do
  use CommonsPub.Web, :live_component



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

  def handle_event("form_changes", data, socket) do
    # attempt anything that's triggered by a form edit

    maybe_fetch = handle_event("fetch_link", data, socket)

    if maybe_fetch do
      maybe_fetch
    else
      CommonsPub.Web.Component.TagAutocomplete.tag_suggest(data, socket)
    end
  end

  def handle_event("fetch_link", %{"content" => %{"url" => url}} = _data, socket)
      when byte_size(url) > 5 do
    if !Map.get(socket.assigns, :fetched_url) or url != Map.get(socket.assigns, :fetched_url) do
      IO.inspect(fetch_url: url)

      fetch =
        with {:ok, fetch} <-
               CommonsPub.Web.GraphQL.MiscSchema.fetch_web_metadata(%{url: url}, nil) do
          IO.inspect(scraped: fetch)
          fetch
        else
          _ ->
            %{}
        end

      {:noreply,
       socket
       |> assign(fetched_url: url, link_input: fetch)
       |> put_flash(:info, "Fetched link...")}
    else
      IO.inspect(ignore_url: url)
      {:noreply, socket}
    end
  end

  def handle_event("fetch_link", _, _socket) do
    nil
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
      # CommonsPub.Web.Plugs.Auth.login(socket, session.current_user, session.token)

      # IO.inspect(context_id, label: "context_id CHOOSEN")

      resource = input_to_atoms(data)

      resource =
        resource
        |> Map.put(
          :public_access,
          CommonsPub.Utils.Text.blank?(Map.get(resource, :public_access))
        )
        |> Map.put(
          :free_access,
          CommonsPub.Utils.Text.blank?(Map.get(resource, :free_access))
        )
        |> Map.put(
          :accessibility_feature,
         ( if !CommonsPub.Utils.Text.blank?(Map.get(resource, :accessibility_feature)),
          do: ["captions", "transcript"],
          else: nil
         )
        )

      IO.inspect(resource_input: resource)

      with {:ok, _resource} <-
             CommonsPub.Web.GraphQL.ResourcesResolver.create_resource(
               %{
                 context_id: context_id,
                 resource: resource,
                 content: input_to_atoms(content),
                 icon: input_to_atoms(icon)
               },
               %{context: %{current_user: socket.assigns.current_user}}
             ) do
        {:noreply,
         socket
         |> put_flash(:info, "Published!")
         |> push_redirect(to: "/instance/timeline")}

        # change redirect
      else
        _e ->
          {:noreply,
           socket
           |> put_flash(:error, "There was an error sharing this link...")}
      end
    end
  end
end
