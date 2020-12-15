defmodule CommonsPub.Web.Component.CommunityPreviewLive do
  use CommonsPub.Web, :live_component

  # import CommonsPub.Profiles.Web.ProfilesHelper

  # def mount(_, _session, socket) do
  #   {:ok, assign(socket, current_user: socket.assigns.current_user)}
  # end

  def update(assigns, socket) do
    # IO.inspect(community_pre_prep: assigns.community)

    community =
      CommonsPub.Profiles.Web.ProfilesHelper.prepare(assigns.community, %{
        icon: true,
        character: true
      })

    # IO.inspect(community_post_prep: community)

    {:ok,
     socket
     |> assign(
       community: community
       #  current_user: assigns.current_user
     )}
  end

  def render(assigns) do
    ~L"""
    <%=
      live_redirect to: "/"<> e(@community, :username, "deleted") do %>
      <div class="community__preview">
        <div class="preview__image" style="background-image: url(<%= e(@community, :icon_url, e(@community, :image_url, "")) %>)"></div>
        <div class="preview__info">
          <h3><%= e(@community, :name, "Community") %></h3>
        </div>
      </div>
    <% end %>
    """
  end
end
