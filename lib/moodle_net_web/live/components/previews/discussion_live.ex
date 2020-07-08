defmodule MoodleNetWeb.Component.DiscussionPreviewLive do
  use Phoenix.LiveComponent
  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.Helpers.{Discussion}

  def mount(thread, _session, socket) do
    {:ok, assign(socket, thread: thread)}
  end

  @spec update(map, Phoenix.LiveView.Socket.t()) :: {:ok, any}
  def update(assigns, socket) do
    if(Map.has_key?(assigns, :thread)) do
      {:ok,
       assign(socket,
         thread: Discussion.prepare_comment(assigns.thread)
       )}
    else
      {:ok, assign(socket, thread: %{})}
    end
  end

  def render(assigns) do
    # IO.inspect(assigns)
    ~L"""
    <div class="discussion__preview">
      <a href="/discussion/<%= @thread.id %>">
        <h2 class="discussion__title"><%= e(@thread, :name, "Thread without title") %></h2>
        <div class="discussion__meta">
          <div class="meta__time">
            Started <%= @thread.published_at %> by <%= @thread.creator.name %>
          </div>
          <div class="preview__meta">
            <div class="meta__item">
              <i class="feather-message-square"></i>
              5
            </div>
            <div class="meta__item">
              <i class="feather-star"></i>
              13
            </div>
          </div>
        </div>
      </a>
    </div>
    """
  end
end
