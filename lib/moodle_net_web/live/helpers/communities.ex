defmodule MoodleNetWeb.Helpers.Communities do
  alias MoodleNet.{
    Repo
  }

  alias MoodleNetWeb.GraphQL.{
    CommonResolver,
    UsersResolver,
    CommunitiesResolver
  }

  import MoodleNetWeb.Helpers.Common
  alias MoodleNetWeb.Helpers.Profiles

  def community_load(_socket, page_params, preload) do
    # IO.inspect(socket)

    username = e(page_params, "username", nil)

    {:ok, community} =
      if(!is_nil(username)) do
        CommunitiesResolver.community(%{username: username}, %{})
      else
        {:ok, %{}}
      end

    Profiles.prepare(community, preload)
  end

  def user_communities(for_user, current_user) do
    {:ok, communities} =
      UsersResolver.community_follows_edge(
        for_user,
        %{limit: 10},
        %{context: %{current_user: current_user}}
      )

    # IO.inspect(my_follows: communities)

    # FIXME: communities should be joined rather than queried one by one
    communities =
      Enum.map(
        communities.edges,
        &CommonResolver.context_edge(&1, nil, nil)
      )

    communities =
      Enum.map(
        communities,
        &Profiles.prepare(&1, %{icon: true, image: true, actor: true})
      )

    communities
  end
end
