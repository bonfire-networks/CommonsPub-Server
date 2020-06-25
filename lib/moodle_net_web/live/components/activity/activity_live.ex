defmodule MoodleNetWeb.Component.ActivityLive do
  use Phoenix.LiveComponent
  alias MoodleNetWeb.Component.StoryPreviewLive
  alias MoodleNetWeb.Component.CommentPreviewLive
  alias MoodleNetWeb.Component.CommunityPreviewLive
  alias MoodleNetWeb.Component.DiscussionPreviewLive

  alias MoodleNet.{
    Repo,
    Meta.Pointers
  }

  def mount(activity, _session, socket) do
    {:ok, assign(socket, activity: activity)}
  end

  def update(assigns, socket) do
    if(Map.has_key?(assigns, :activity)) do
      activity =
        if(!is_nil(assigns.activity.context_id)) do
          {:ok, pointer} = Pointers.one(id: assigns.activity.context_id)
          context = Pointers.follow!(pointer)

          type =
            context.__struct__
            |> Module.split()
            |> Enum.at(-1)
            |> String.downcase()

          assigns.activity
          |> Map.merge(%{context_type: type})
          |> Map.merge(%{context: context})
        else
          assigns.activity
        end

      activity = Repo.preload(activity, :creator)

      creator = activity.creator
      creator = Repo.preload(creator, :icon)
      creator = Repo.preload(creator, :actor)

      icon =
        if(is_nil(creator.icon)) do
          # TODO: replace with email
          MoodleNet.Users.Gravatar.url(creator.id)
        else
          creator.icon
        end

      creator =
        creator
        |> Map.merge(%{icon: icon})

      {:ok, from_now} =
        Timex.shift(activity.published_at, minutes: -3)
        |> Timex.format("{relative}", :relative)

      {:ok,
       assign(socket,
         activity:
           activity
           |> Map.merge(%{published_at: from_now})
           |> Map.merge(%{creator: creator})
       )}
    else
      {:ok, assign(socket, activity: %{})}
    end
  end

  def activity_verb_object(%{verb: verb, context_type: context_type} = activity) do
    cond do
      activity.context_type == "flag" ->
        "flagged a " <> activity.context_type

      activity.context_type == "like" ->
        "starred a " <> activity.context_type

      activity.context_type == "follow" ->
        "followed a " <> activity.context_type

      activity.context_type == "resource" ->
        "added a " <> activity.context_type

      activity.context_type == "comment" ->
        cond do
          activity.context.reply_to_id ->
            "replied to a discussion"

          true ->
            "started a discussion"
        end

      activity.verb == "created" ->
        "created a " <> activity.context_type

      activity.verb == "updated" ->
        "updated a " <> activity.context_type

      true ->
        "acted on a " <> activity.context_type
    end
  end

  def activity_verb_object(%{verb: verb} = activity) do
    verb <> " something"
  end

  def activity_verb_object(%{context_type: context_type} = activity) do
    "did " <> context_type
  end

  def activity_verb_object(activity) do
    "did something"
  end

  @doc "Returns a value from a map, or a fallback if not present"
  def e(map, key, fallback) do
    Map.get(map, key, fallback)
  end

  @doc "Returns a value from a nested map, or a fallback if not present"
  def e(map, key1, key2, fallback) do
    e(e(map, key1, %{}), key2, fallback)
  end

  def e(map, key1, key2, key3, fallback) do
    e(e(map, key1, key2, %{}), key3, fallback)
  end

  def render(assigns) do
    ~L"""
    <div class="component__activity">
      <div class="activity__info">
        <img src="<%= e(@activity, :creator, :icon, MoodleNet.Users.Gravatar.url("default")) %>" alt="icon" />
        <div class="info__meta">
          <div class="meta__action">
            <a href="/@<%= e(@activity, :creator, :actor, :preferred_username, "deleted") %>"><%= e(@activity, :creator, :name, "Somebody") %></a>
            <p><a href="<%= e(@activity, :context, :canonical_url, "/discussion") %>"><%= activity_verb_object(@activity) %></a></p>
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
