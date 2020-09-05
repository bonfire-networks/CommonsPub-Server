defmodule CommonsPub.Web.My.NewCategoryLive do
  use CommonsPub.Web, :live_component

  import CommonsPub.Utils.Web.CommonHelper

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
    }
  end

  def handle_event("toggle_category", _data, socket) do
    {:noreply, assign(socket, :toggle_category, !socket.assigns.toggle_category)}
  end

  def handle_event("new_category", %{"name" => name, "context_id" => context_id} = data, socket) do
    if(is_nil(name) or !Map.has_key?(socket.assigns, :current_user)) do
      {:noreply,
       socket
       |> put_flash(:error, "Please enter a name...")}
    else
      category = input_to_atoms(data)
      IO.inspect(data, label: "category to create")

      {:ok, category} =
        CommonsPub.Tag.Categories.create(
          socket.assigns.current_user,
          %{category: category, caretaker_id: context_id, parent_category: context_id}
        )

      # TODO: handle errors
      IO.inspect(category, label: "category created")

      id = category.character.preferred_username || category.id

      if(id) do
        {:noreply,
         socket
         |> put_flash(:info, "Category created!")
         # change redirect
         |> push_redirect(to: "/++" <> id)}
      else
        {:noreply,
         socket
         |> push_redirect(to: "/instance/categories/")}
      end
    end
  end
end
