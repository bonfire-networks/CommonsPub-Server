defmodule MoodleNetWeb.Component.UnknownPreviewLive do
  use Phoenix.LiveComponent

  import MoodleNetWeb.Helpers.Common

  def update(assigns, socket) do
    object = prepare_common(assigns.object)
    IO.inspect(unknown_preview: object)

    {:ok,
     assign(socket,
       object: assigns.object
     )}
  end

  def render(assigns) do
    ~L"""
    <div class="story__preview">
      <div class="preview__info">
        <h2><a href="<%= e(@object, :link, "#") %>"><%= e(@object, :name, "") %></a></h2>
        <p><%= e(@object, :summary, "") %></p>
        <div class="preview__meta">
          <div class="meta__item">
            <i class="feather-message-square"></i>
            5
          </div>
          <div class="meta__item">
            <i class="feather-star"></i>
            13
          </div>
        </div>
      </div>
      <div class="preview__icon" style="background-image: url('<%= e(@object, :icon, "") %>')"></div>
    </div>
    """
  end
end
