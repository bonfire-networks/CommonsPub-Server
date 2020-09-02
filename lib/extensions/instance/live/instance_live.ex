defmodule CommonsPub.Web.InstanceLive do
  use CommonsPub.Web, :live_view
  # alias CommonsPub.Web.Helpers.{Profiles}
  import CommonsPub.Web.Helpers.Common

  alias CommonsPub.Web.InstanceLive.{
    InstanceActivitiesLive,
    InstanceMembersLive,
    InstanceMembersPreviewLive,
    InstanceCommunitiesLive,
    InstanceCollectionsLive,
    InstanceCategoriesLive
  }

  def mount(params, session, socket) do
    socket = init_assigns(params, session, socket)

    {:ok,
     socket
     |> assign(
       page_title: "Home",
       hostname: CommonsPub.Instance.hostname(),
       description: CommonsPub.Instance.description(),
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

  @doc """
  Forward PubSub activities in timeline to our timeline component
  """
  def handle_info({:pub_feed_activity, activity}, socket),
    do:
      CommonsPub.Web.Helpers.Activites.pubsub_activity_forward(
        activity,
        CommonsPub.Web.InstanceLive.InstanceActivitiesLive,
        :instance_timeline,
        socket
      )

  # defp link_body(name, icon) do
  #   assigns = %{name: name, icon: icon}

  #   ~L"""
  #     <i class="<%= @icon %>"></i>
  #     <%= @name %>
  #   """
  # end
end
