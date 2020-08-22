defmodule MoodleNetWeb.Component.TabNotFoundLive do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <h3 class="area__title">Section not found</h3>
    <div class="selected__area"></div>
    """
  end
end
