defmodule MoodleNetWeb.HomeLive do
  use MoodleNetWeb, :live_view
  alias MoodleNetWeb.Component.HeaderLive
  alias MoodleNetWeb.Component.ActivityLive
  alias MoodleNetWeb.GraphQL.CommunitiesResolver
  alias MoodleNetWeb.GraphQL.InstanceResolver

  def mount(_params, _session, socket) do
    {:ok, communities_pages} = CommunitiesResolver.communities(%{}, %{})
    {:ok, outboxes} = InstanceResolver.outbox_edge(%{}, %{limit: 10}, %{})
    {:ok, assign(socket,
    hostname: MoodleNet.Instance.hostname,
    description: MoodleNet.Instance.description,
    outbox: outboxes.edges,
    feed: communities_pages.edges )}
  end

  def render(assigns) do
    ~L"""
    <div class="page">
    <%= live_component(
        @socket,
        HeaderLive,
        icon: "https://home.next.moodle.net/uploads/01E9TQEVAKAVNZCQVE94NJA7TP/moebius4.jpeg"
      )
    %>
    <section class="page__wrapper">
      <div class="instance_hero">
        <h1><%= @hostname %></h1>
        <h4><%= @description %></h4>
      </div>
      <div class="mainContent__navigation home__navigation">
        <a href="#" class="navigation__item">
          <i class="feather-heart"></i>About
        </a>
        <a href="#" class="navigation__item active">
          <i class="feather-activity"></i>Timeline
        </a>
        <a href="#" class="navigation__item">
          <i class="feather-file-text"></i>
          Members
        </a>
      </div>
      <div class="mainContent__selected">
          <div class="selected__header">
            <h3>About</h3>
          </div>
          <div class="selected__area">

            <%= for activity <- @outbox do %>
              <%= live_component(
                    @socket,
                    ActivityLive,
                    activity: activity
                  )
                %>
            <% end %>

            <!-- div class="markdown-body"></div -->
          </div>
        </div>
      </div>
    </section>
    </div>
    """
  end

end
