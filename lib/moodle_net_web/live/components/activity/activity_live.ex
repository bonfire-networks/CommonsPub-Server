defmodule MoodleNetWeb.Component.ActivityLive do
  use Phoenix.LiveComponent

  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.Component.StoryPreviewLive
  alias MoodleNetWeb.Component.CommentPreviewLive
  alias MoodleNetWeb.Component.CommunityPreviewLive
  alias MoodleNetWeb.Component.DiscussionPreviewLive

  alias MoodleNetWeb.Helpers.{Activites}

  def mount(activity, _session, socket) do
    {:ok, assign(socket, activity: activity)}
  end

  def update(assigns, socket) do
    if(Map.has_key?(assigns, :activity)) do
      {:ok,
       assign(socket,
         activity: Activites.prepare(assigns.activity)
       )}
    else
      {:ok, assign(socket, activity: %{})}
    end
  end

  def render(assigns) do
    # IO.inspect(assigns.activity)

    ~L"""
    <div id="<%= e(@activity, :id, "") %>" class="component__activity">
      <div class="activity__info">
        <img src="<%= e(@activity, :creator, :icon, "") %>" alt="icon" />
        <div class="info__meta">
          <div class="meta__action">
            <a href="/@<%= e(@activity, :creator, :actor, :preferred_username, "deleted") %>"><%= e(@activity, :creator, :name, "Somebody") %></a>
            <p><a href="<%= e(@activity, :context, :canonical_url, "/discussion") %>"><%= e(@activity, :verb_object, "did something") %></a></p>
          </div>
          <div class="meta__secondary">
            <%= e(@activity, :published_at, "one day") %>
          </div>
        </div>
      </div>
      <div class="activity__preview">

        <%= if(Map.has_key?(@activity, :context_type)) do
        cond do
            @activity.context_type == "community" ->
              live_component(
                @socket,
                CommunityPreviewLive,
                community: @activity.context
              )
              @activity.context_type == "comment" ->
                live_component(
                  @socket,
                  CommentPreviewLive,
                  comment: @activity.context
                )
              true ->
                live_component(
                  @socket,
                  StoryPreviewLive
                )
            end
          end %>
      </div>
    </div>
    """
  end
end
