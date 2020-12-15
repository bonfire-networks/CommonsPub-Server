defmodule CommonsPub.Web.Component.FlagPreviewLive do
  use CommonsPub.Web, :live_component

  alias CommonsPub.Web.Component.ActivityLive

  def render(assigns) do
    ~L"""
    <div class="flag__preview">
      <%=live_component(
            @socket,
            ActivityLive,
            activity: Map.merge(@flag , %{display_verb: "created"}),
            no_actions: true,
            current_user: e(@current_user, %{})
          )
      %>
      </div>
    """
  end
end
