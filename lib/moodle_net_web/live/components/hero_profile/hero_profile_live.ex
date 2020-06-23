defmodule MoodleNetWeb.Component.HeroProfileLive do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
      <div class="mainContent__hero">
        <div class="hero__image">
          <img alt="background image" src="<%= @image %>" />
        </div>
        <div class="hero__info">
          <div class="info__icon">
            <img alt="profile pic" src="<%= @icon %>" />
          </div>
          <div class="info__name"><%= @name %></div>
          <div class="info__username"><%= @username %></div>
          <div class="info__details">
            <div class="details__meta"><i class="feather-external-link"></i><%= @website %></div>
            <div class="details__meta"><i class="feather-map-pin"></i><%= @location %></div>
            <div class="details__meta"><i class="feather-mail"></i><%= @email %></div>
          </div>
        </div>
      </div>
    """
  end
end
