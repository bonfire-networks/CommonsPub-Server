defmodule CommonsPub.Web.CommunityLive.CommunityMembersPreviewLive do
  use CommonsPub.Web, :live_component
  alias CommonsPub.Profiles.Web.ProfilesHelper
  import CommonsPub.Utils.Web.CommonHelper

  alias CommonsPub.Web.Component.{
    UserPreviewLive
  }

  def update(assigns, socket) do
    # IO.inspect(assigns, label: "ASSIGNS:")
    {
      :ok,
      socket
      |> assign(assigns)
      |> fetch(assigns)
    }
  end

  def fetch(socket, assigns) do
    {:ok, follows} =
      CommonsPub.Web.GraphQL.FollowsResolver.followers_edge(
        %{id: assigns.community.id},
        %{limit: 10},
        %{context: %{current_user: assigns.current_user}}
      )

    IO.inspect(follows: follows)

    followings =
      Enum.map(
        follows.edges,
        &ProfilesHelper.fetch_users_from_creator(&1)
      )

    # IO.inspect(followings, label: "User COMMUNITY:")

    # followings = Enum.dedup_by(followings, fn %{id: id} -> id end)

    assign(socket,
      members: followings,
      has_next_page: follows.page_info.has_next_page,
      after: follows.page_info.end_cursor,
      before: follows.page_info.start_cursor
    )
  end

  def handle_event("load-more", _, socket),
    do: CommonsPub.Utils.Web.CommonHelper.paginate_next(&fetch/2, socket)
end
