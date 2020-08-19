defmodule MoodleNetWeb.Component.CategoryPreviewLive do
  use Phoenix.LiveComponent

  import MoodleNetWeb.Helpers.Common

  def category_link(cat) do
    "/++" <> e(cat, :id, "#no-parent")
  end

  def update(assigns, socket) do
    # object = prepare_common(assigns.object)

    object =
      maybe_preload(assigns.object, [
        :profile,
        :character,
        parent_category: [:profile, :character, parent_category: [:profile, :character]]
      ])

    IO.inspect(category_preview: object)

    {:ok,
     assign(socket,
       object: object
     )}
  end

  def render(assigns) do
    ~L"""
    <div class="story__preview">
      <div class="preview__info">
        <h2>
        <a href="<%= category_link(e(@object, :parent_category, :parent_category, nil)) %>"><%= e(@object, :parent_category, :parent_category, :profile, :name, "") %></a>
        »
        <a href="<%= category_link(e(@object, :parent_category, nil)) %>"><%= e(@object, :parent_category, :profile, :name, "") %></a>
        »
        <a href="<%= category_link(@object) %>"><%= e(@object, :name, "") %></a></h2>
        <p><%= e(@object, :summary, "") %></p>

      </div>
    </div>
    """
  end
end
