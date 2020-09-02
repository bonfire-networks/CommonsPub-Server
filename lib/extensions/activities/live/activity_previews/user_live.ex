defmodule CommonsPub.Web.Component.UserPreviewLive do
  use Phoenix.LiveComponent
  import CommonsPub.Utils.Web.CommonHelper

  # alias CommonsPub.Profiles.Web.ProfilesHelper

  # def update(assigns, socket) do
  #   {:ok, assign(socket, user: ProfilesHelper.prepare(assigns.user, %{icon: true, ))} # do this in parent view instead
  # end

  def render(assigns) do
    ~L"""
    <%= live_redirect to: "/"<>e(@user, :username, "unknown") do %>
      <div class="user__preview">
        <div class="preview__image" style="background-image: url(<%= e(@user, :icon_url, "") %>)"></div>
        <div class="preview__info">
          <h3><%= @user.name %></h3>
          <h4><%= e(@user, :username, "") %></h4>
        </div>
      </div>
      <% end %>
    """
  end
end
