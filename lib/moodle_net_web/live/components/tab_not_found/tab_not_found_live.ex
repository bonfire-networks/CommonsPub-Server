defmodule MoodleNetWeb.Component.TabNotFoundLive do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div class="selected__header">
      <h3>Section not found</h3>
    </div>
    <div class="selected__area"></div>
    """
  end
end


