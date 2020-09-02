defmodule CommonsPub.Web.Component.DiscussionPreviewLive do
  use Phoenix.LiveComponent
  import CommonsPub.Web.Helpers.Common

  alias CommonsPub.Web.Helpers.{Discussions}

  def mount(thread, _session, socket) do
    {:ok, assign(socket, thread: thread)}
  end

  @spec update(map, Phoenix.LiveView.Socket.t()) :: {:ok, any}
  def update(assigns, socket) do
    if(Map.has_key?(assigns, :thread)) do
      {:ok,
       assign(socket,
         thread: Discussions.prepare_thread(assigns.thread, assigns.current_user)
       )}
    else
      {:ok, assign(socket, thread: %{})}
    end
  end

  def render(assigns) do
    IO.inspect(assigns, label: "Assign:")

    ~L"""
    <div class="discussion__preview">
      <%= live_redirect to: "/!"<> @thread.id <>"/discuss" do %>
        <h2 class="discussion__title"><%= if @thread.name == nil, do: "Thread without title", else: @thread.name %></h2>
        <div class="discussion__meta">
          <div class="meta__time">
            Started <%= @thread.published_at %> by <%= e(@thread, :creator, :name, "an unknown person") %>
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
        <% end %>
    </div>
    """
  end
end
