defmodule MoodleNetWeb.InstanceLive do
  use MoodleNetWeb, :live_view
  # alias MoodleNetWeb.Helpers.{Profiles}
  import MoodleNetWeb.Helpers.Common

  alias MoodleNetWeb.InstanceLive.{
    InstanceActivitiesLive,
    InstanceMembersLive,
    InstanceMembersPreviewLive,
    InstanceCommunitiesLive,
    InstanceCollectionsLive,
    InstanceCategoriesLive
  }

  def mount(params, session, socket) do
    IO.inspect(instance_session: session)
    socket = init_assigns(params, session, socket)

    {:ok,
     socket
     |> assign(
       page_title: "Home",
       hostname: MoodleNet.Instance.hostname(),
       description: MoodleNet.Instance.description(),
       activities: [],
       selected_tab: "about"
     )}
  end

  def handle_params(%{"tab" => tab}, _url, socket) do
    {:noreply, assign(socket, selected_tab: tab)}
  end

  def handle_params(_, _url, socket) do
    {:noreply, socket}
  end

  def handle_info({:pub_feed_activity, activity}, socket) do
    IO.inspect(handle_info: activity)

    send_update(MoodleNetWeb.InstanceLive.InstanceActivitiesLive,
      id: :timeline,
      activity: activity
    )

    {:noreply, socket}

    # {:noreply, update(socket, :activities, fn activities -> [activity | activities] end)}
  end

  # defp link_body(name, icon) do
  #   assigns = %{name: name, icon: icon}

  #   ~L"""
  #     <i class="<%= @icon %>"></i>
  #     <%= @name %>
  #   """
  # end
end
