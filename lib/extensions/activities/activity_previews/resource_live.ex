defmodule MoodleNetWeb.Component.ResourcePreviewLive do
  use Phoenix.LiveComponent
  import MoodleNetWeb.Helpers.Common
  import MoodleNetWeb.Helpers.Profiles

  # def mount(_, _session, socket) do
  #   {:ok, assign(socket, current_user: socket.assigns.current_user)}
  # end

  def update(assigns, socket) do
    # IO.inspect(resource_pre_prep: assigns.resource)

    # resource = MoodleNetWeb.Helpers.Profiles.prepare(assigns.resource, %{icon: true, actor: true})

    resource = prepare_common(assigns.resource)

    IO.inspect(resource_post_prep: resource)

    {:ok,
     socket
     |> assign(
       resource: resource
       #  current_user: assigns.current_user
     )}
  end

  def render(assigns) do
    ~L"""
    <a href="<%= e(@resource, :link, "#") %>" target="_blank">
      <div class="resource__preview">
      <%= if e(@resource, :icon, nil) do %>
        <img src="<%= e(@resource, :icon, "")%>" height="40"/>
      <% end %>

      <%= if !e(@resource, :icon, nil) do %>
      <svg height="40" version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
      viewBox="0 0 404.48 404.48" style="enable-background:new 0 0 404.48 404.48;" xml:space="preserve">
    <path style="fill:#DADEE0;" d="M376.325,87.04c0-16.896-13.824-30.72-30.72-30.72h-230.41c-16.896,0-30.72,13.824-30.72,30.72
     v286.72c0,16.896,13.824,30.72,30.72,30.72H289.26l87.04-81.92L376.325,87.04z"/>
    <path style="fill:#1BB7EA;" d="M84.475,87.04c0-16.896,13.824-30.72,30.72-30.72h204.81v-25.6c0-16.896-13.824-30.72-30.72-30.72
     H58.875c-16.896,0-30.72,13.824-30.72,30.72v286.72c0,16.896,13.824,30.72,30.72,30.72h25.6V87.04z"/>
    <path style="fill:#F2F2F2;" d="M319.985,322.56h56.32l-87.04,81.92v-51.2C289.265,336.384,303.089,322.56,319.985,322.56z"/>
    <g>
     <path style="fill:#1F4254;" d="M161.275,192h138.24c4.245,0,7.68-3.441,7.68-7.68c0-4.244-3.436-7.68-7.68-7.68h-138.24
       c-4.244,0-7.68,3.436-7.68,7.68C153.595,188.559,157.03,192,161.275,192"/>
     <path style="fill:#1F4254;" d="M161.275,140.8h138.24c4.245,0,7.68-3.441,7.68-7.68c0-4.244-3.436-7.68-7.68-7.68h-138.24
       c-4.244,0-7.68,3.436-7.68,7.68C153.595,137.359,157.03,140.8,161.275,140.8"/>
     <path style="fill:#1F4254;" d="M161.275,243.2h138.24c4.245,0,7.68-3.441,7.68-7.68c0-4.244-3.436-7.68-7.68-7.68h-138.24
       c-4.244,0-7.68,3.436-7.68,7.68C153.595,239.759,157.03,243.2,161.275,243.2"/>
     <path style="fill:#1F4254;" d="M161.275,294.4h76.8c4.244,0,7.68-3.441,7.68-7.68c0-4.245-3.436-7.68-7.68-7.68h-76.8
       c-4.244,0-7.68,3.435-7.68,7.68C153.595,290.959,157.03,294.4,161.275,294.4"/>
    </g>
    <g>
    </g>
    <g>
    </g>
    <g>
    </g>
    <g>
    </g>
    <g>
    </g>
    <g>
    </g>
    <g>
    </g>
    <g>
    </g>
    <g>
    </g>
    <g>
    </g>
    <g>
    </g>
    <g>
    </g>
    <g>
    </g>
    <g>
    </g>
    <g>
    </g>
    </svg>
    <% end %>

        <div class="preview__info">
          <h4><%= e(@resource, :name, "Resource") %></h4>
        </div>
      </div>
    </a>
    """
  end
end
