defmodule MoodleNetWeb.Component.HeroProfileLive do
  use MoodleNetWeb, :live_component

  import MoodleNetWeb.Helpers.Common

  def render(assigns) do
    ~L"""
      <div class="mainContent__hero">
        <div class="hero__image">
          <img alt="background image" src="<%= @user.image_url %>" />
        </div>
        <div class="hero__info">
          <div class="info__icon">
            <img alt="profile pic" src="<%= @user.icon_url %>" />
          </div>
          <div class="info__meta">
            <h1><%= @user.name %></h1>
            <h4 class="info__username">@<%= e(@user, :actor, :preferred_username, "") %></h4>
            <div class="info__details">
              <div class="details__meta"><a href="<%= @user.website %>" target="_blank"><i class="feather-external-link"></i> <%= e(@user, :website_friendly, "") %></a></div>
              <div class="details__meta"><i class="feather-map-pin"></i><%= @user.location %></div>
            </div>
          </div>
        </div>
      </div>
    """
  end
end
