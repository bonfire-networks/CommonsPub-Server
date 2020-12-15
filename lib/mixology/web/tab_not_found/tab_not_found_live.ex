defmodule CommonsPub.Web.Component.TabNotFoundLive do
  use CommonsPub.Web, :live_component

  def render(assigns) do
    ~L"""
    <h3 class="area__title">Section not found</h3>
    <div class="selected__area"></div>
    """
  end
end
