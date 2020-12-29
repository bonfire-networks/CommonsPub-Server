defmodule CommonsPub.Web.InstanceLive.InstanceCategoriesPageLive do
  use CommonsPub.Web, :live_view



  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)

    {:ok,
     socket
     |> assign(current_user: socket.assigns.current_user)}
  end

  def render(assigns) do
    ~L"""
    <%= live_component(
      @socket,
      CommonsPub.Web.InstanceLive.InstanceCategoriesLive,
      # selected_tab: @selected_tab,
      id: :categories,
      current_user: @current_user,
      categories: [],
      page: 1,
      has_next_page: false,
      after: [],
      before: [],
      pagination_target: "#instance-categories"
    ) %>
    """
  end
end
