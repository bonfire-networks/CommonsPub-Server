defmodule MoodleNetWeb.Component.HeroProfileLive do
  use MoodleNetWeb, :live_component

  import MoodleNetWeb.Helpers.Common

  def render(assigns) do
    ~L"""
      <div class="suphero">
        <div class="suphero__left">
          <img alt="profile pic" src="<%= @user.icon_url %>" />
          <h4><%= @user.name %></h4>
        </div>
        <div class="suphero__actions">
          <%= if @current_user do %>
            <a href="/my/settings" class="button">Settings</a>
          <% else %>
            <button class="button">Follow</button>
          <% end %>
          <button class="button button-outline">
            <i class="feather-more-horizontal"></i>
          </button>
        </div>
      </div>


      <div class="mainContent__hero">
        <div class="hero__image">
          <img alt="background image" src="<%= @user.image_url %>" />
        </div>
        <div class="hero__info">
          <div class="info__icon">
            <img alt="profile pic" src="<%= @user.icon_url %>" />
          </div>
          <div class="info__meta">
            <div class="info__name"><%= @user.name %></div>
            <div class="info__username">@<%= e(@user, :actor, :preferred_username, "") %></div>
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
