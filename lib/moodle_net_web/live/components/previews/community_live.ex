defmodule MoodleNetWeb.Component.CommunityPreviewLive do
  use Phoenix.LiveComponent
  import MoodleNetWeb.Helpers.Common
  import MoodleNetWeb.Helpers.Profiles

  def render(assigns) do
    ~L"""
    <%=
      community = MoodleNetWeb.Helpers.Profiles.prepare(@community, %{icon: true, actor: true})
      live_redirect to: "/&"<> e(community, :actor, :preferred_username, "deleted") do %>
      <div class="community__preview">
        <div class="preview__image" style="background-image: url(<%= e(community, :icon_url, e(@community, :image_url, "")) %>)"></div>
        <div class="preview__info">
          <h3><%= e(@community, :name, "Community") %></h3>
        </div>
      </div>
    <% end %>
    """
  end
end
