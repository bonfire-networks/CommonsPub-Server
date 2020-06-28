defmodule MoodleNetWeb.Component.AboutLive do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
      <div class="about__preview">
        <div class="markdown-body"><%= @description %></div>
      </div>
    """
  end
end
