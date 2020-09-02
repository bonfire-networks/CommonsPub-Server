defmodule MoodleNetWeb.Component.CollectionPreviewLive do
  use Phoenix.LiveComponent
  import MoodleNetWeb.Helpers.Common
  # import MoodleNetWeb.Helpers.Profiles

  # def mount(_, _session, socket) do
  #   {:ok, assign(socket, current_user: socket.assigns.current_user)}
  # end

  def update(assigns, socket) do
    # IO.inspect(collection_pre_prep: assigns.collection)

    collection =
      MoodleNetWeb.Helpers.Profiles.prepare(assigns.collection, %{icon: true, actor: true})

    # IO.inspect(collection_post_prep: collection)

    {:ok,
     socket
     |> assign(
       collection: collection
       #  current_user: assigns.current_user
     )}
  end

  def render(assigns) do
    ~L"""
    <%= live_redirect to: "/"<> e(@collection, :username, "deleted") do %>
      <div class="collection__preview">
        <svg width="40" height="40" viewBox="0 0 40 40" focusable="false" class="mc-icon mc-icon-template-content mc-icon-template-content--folder-small brws-file-name-cell-icon" role="img"><g fill="none" fill-rule="evenodd"><path d="M18.422 11h15.07c.84 0 1.508.669 1.508 1.493v18.014c0 .818-.675 1.493-1.508 1.493H6.508C5.668 32 5 31.331 5 30.507V9.493C5 8.663 5.671 8 6.5 8h7.805c.564 0 1.229.387 1.502.865l1.015 1.777s.4.358 1.6.358z" fill="#71B9F4"></path><path d="M18.422 10h15.07c.84 0 1.508.669 1.508 1.493v18.014c0 .818-.675 1.493-1.508 1.493H6.508C5.668 31 5 30.331 5 29.507V8.493C5 7.663 5.671 7 6.5 7h7.805c.564 0 1.229.387 1.502.865l1.015 1.777s.4.358 1.6.358z" fill="#92CEFF"></path></g></svg>
        <div class="preview__info">
          <h4><%= e(@collection, :name, "Collection") %></h4>
        </div>
      </div>
    <% end %>
    """
  end
end
