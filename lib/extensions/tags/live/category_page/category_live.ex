defmodule MoodleNetWeb.Page.Category do
  use MoodleNetWeb, :live_view

  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.Page.Category.SubcategoriesLive
  alias MoodleNetWeb.CommunityLive.CommunityCollectionsLive
  alias MoodleNetWeb.CollectionLive.CollectionResourcesLive

  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)

    {:ok,
     socket
     |> assign(current_user: socket.assigns.current_user)
     |> assign(category: %{})
     |> assign(object_type: nil)}
  end

  def handle_params(%{} = params, _url, socket) do
    # obj = context_fetch(params["id"])

    top_level_category = System.get_env("TOP_LEVEL_CATEGORY", "")

    id =
      if !is_nil(params["id"]) and params["id"] != "" do
        params["id"]
      else
        top_level_category
      end

    {:ok, category} =
      if !is_nil(id) and id != "" do
        CommonsPub.Tag.GraphQL.TagResolver.category(
          %{category_id: id},
          %{context: %{current_user: socket.assigns.current_user}}
        )
      else
        {:ok, %{}}
      end

    {:noreply,
     socket
     |> assign(current_user: socket.assigns.current_user)
     |> assign(category: category)
     |> assign(object_type: context_type(category))
     |> assign(current_context: category)}
  end
end
